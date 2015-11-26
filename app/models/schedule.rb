class Schedule < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :scheduable, polymorphic: true

  has_many :schedule_exception_rules, dependent: :destroy
  has_many :schedule_rules, dependent: :destroy

  before_validation :validate_schedule_rules
  before_save :create_schedule_from_simple_settings, if: :use_simple_schedule
  before_save :set_timezone

  validates_presence_of :sr_start_datetime, :sr_from_hour, :sr_to_hour, if: :use_simple_schedule
  validates_numericality_of :sr_every_hours, greater_than_or_equal_to: 0, allow_nil: true , if: :use_simple_schedule

  validates_associated :schedule_exception_rules, :schedule_rules
  validates_length_of :schedule_rules, maximum: 10

  accepts_nested_attributes_for :schedule_exception_rules, allow_destroy: true
  accepts_nested_attributes_for :schedule_rules, allow_destroy: true, reject_if: lambda { |params| params[:run_hours_mode].blank? && params[:run_dates_mode].blank? }

  attr_accessor :timezone

  after_validation  do
    self.sr_days_of_week = self.sr_days_of_week.reject(&:blank?)
  end


  def schedule
    @schedule ||= Time.use_zone(scheduable.try(:timezone) || Time.zone.name) do
      if IceCube::Schedule === super
        super
      else
        IceCube::Schedule.from_hash(JSON.parse(super || '{}'))
      end.tap { |s| s.start_time = Time.zone.now if self.schedule_rules.count > 0 }
    end
  end

  def set_timezone
    schedule.start_time = start_datetime_with_timezone
    self.schedule = schedule.to_hash.to_json
  end

  def create_schedule_from_simple_settings
    @schedule = IceCube::Schedule.new(start_datetime_with_timezone)
    rule = IceCube::Rule.weekly.day(sr_days_of_week.map(&:to_i))
    if sr_every_hours.to_i > 0
      step = sr_every_hours
      hour = sr_start_datetime.hour
      hours = []
      # add all hours after first event
      loop do
        hours << hour
        hour += step
        break if hour > sr_to_hour.hour + sr_from_hour.min.to_f / 60
      end
      # add all hours before the first event
      hour = sr_start_datetime.hour - step
      loop do
        break if hour < sr_to_hour.hour + sr_from_hour.min.to_f / 60
        hours << hour
        hour -= step
      end
      rule.hour_of_day(hours.sort)
    end
    @schedule.add_recurrence_rule rule
    self.schedule = @schedule.to_hash.to_json
  end

  def create_schedule_from_schedule_rules
    Time.use_zone(scheduable.try(:timezone) || timezone) do
      @schedule = IceCube::Schedule.new(start_datetime_with_timezone)
      has_recurring_rule = false
      schedule_rules.find_each do |schedule_rule|
        Array(Schedule::IceCubeRuleBuilder.new(schedule_rule).to_rule).each do |rule|
          case rule
          when IceCube::Rule
            has_recurring_rule = true
            @schedule.add_recurrence_rule(rule)
          else
            @schedule.add_recurrence_time(rule)
          end
        end
      end
      self.schedule = @schedule
    end

    self.update_attribute(:schedule, @schedule.to_hash.to_json)
    save!
  end

  def validate_schedule_rules
    Time.use_zone(timezone) do
      schedule_rules.each { |sr| sr.parse_user_input }
    end
  end

  def days_of_week_selected
    if self.sr_days_of_week.reject(&:blank?).blank?
      self.errors.add(:sr_days_of_week, :blank)
    end
  end

  def use_simple_schedule
    read_attribute(:use_simple_schedule) && !PlatformContext.current.instance.new_ui?
  end

  def use_schedule_rules
    PlatformContext.current.instance.priority_view_path == 'new_ui'
  end

  def start_datetime_with_timezone
    start_time = if schedule_rules.size > 0
                   start_at || Time.now
                 elsif use_simple_schedule
                   sr_start_datetime
                 else
                   schedule.start_time
                 end
    utc_offset = start_time.utc_offset
    start_time_in_zone = (start_time.utc + utc_offset).in_time_zone(scheduable.try(:timezone))
    start_time_in_zone - start_time_in_zone.utc_offset
  end

end

