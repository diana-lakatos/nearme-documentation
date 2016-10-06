require 'ice_cube'

class Schedule < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :scheduable, polymorphic: true, touch: true, inverse_of: :schedule

  has_many :schedule_exception_rules, dependent: :destroy
  has_many :schedule_rules, dependent: :destroy

  before_validation :validate_schedule_rules
  before_save :set_timezone

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
      end.tap do |s|
        if self.schedule_rules.count > 0
          s.start_time = Time.zone.now
          # We add the start time as an exception otherwise we'd always get the start time
          s.add_exception_time(s.start_time)
        end
      end
    end
  end

  def schedule_exception_ranges(start_date)
    schedule_exception_rules.future(start_date || Time.zone.now).map(&:time_range).flatten
  end

  def set_timezone
    schedule.start_time = start_datetime_with_timezone
    self.schedule = schedule.to_hash.except(:start_date).to_json
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

  def excluded_ranges_for(start_date, end_date=nil)
    return [] unless unavailable_period_enabled?

    ser = schedule_exception_rules.where('duration_range_end > ?', start_date )
    ser = ser.where('duration_range_start < ?', end_date ) if end_date
    ser.select('duration_range_start, duration_range_end').map do |ser|
      ser.duration_range_start..ser.duration_range_end.end_of_day
    end
  end

  def validate_schedule_rules
    Time.use_zone(timezone) do
      schedule_rules.each { |sr| sr.parse_user_input }
      schedule_exception_rules.each { |sr| sr.parse_user_input }
    end
  end

  def days_of_week_selected
    if self.sr_days_of_week.reject(&:blank?).blank?
      self.errors.add(:sr_days_of_week, :blank)
    end
  end

  def start_datetime_with_timezone
    start_time = if schedule_rules.size > 0
                   start_at || Time.now
                 else
                   schedule.start_time
                 end
    utc_offset = start_time.utc_offset
    start_time_in_zone = (start_time.utc + utc_offset).in_time_zone(scheduable.try(:timezone))
    start_time_in_zone - start_time_in_zone.utc_offset
  end

end

