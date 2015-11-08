class Schedule < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :scheduable, polymorphic: true

  has_many :schedule_exception_rules, dependent: :destroy

  before_save :create_schedule_from_simple_settings, if: :use_simple_schedule
  before_save :set_timezone

  validates_presence_of :sr_start_datetime, :sr_from_hour, :sr_to_hour, if: :use_simple_schedule
  validates_numericality_of :sr_every_hours, greater_than_or_equal_to: 0, allow_nil: true , if: :use_simple_schedule

  accepts_nested_attributes_for :schedule_exception_rules, allow_destroy: true

  after_validation  do
    self.sr_days_of_week = self.sr_days_of_week.reject(&:blank?)
  end


  def schedule
    @schedule ||= if IceCube::Schedule === super
                    super
                  else
                    IceCube::Schedule.from_hash(JSON.parse(super || '{}'))
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
    schedule.add_recurrence_rule rule
    self.schedule = @schedule.to_hash.to_json
  end

  def days_of_week_selected
    if self.sr_days_of_week.reject(&:blank?).blank?
      self.errors.add(:sr_days_of_week, :blank)
    end
  end

  def start_datetime_with_timezone
    start_time =  use_simple_schedule ? sr_start_datetime : sr_start_datetime
    utc_offset = start_time.utc_offset
    start_time_in_zone = (start_time.utc + utc_offset).in_time_zone(scheduable.try(:timezone))
    start_time_in_zone - start_time_in_zone.utc_offset
  end

end

