class AvailabilityRule < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid
  # attr_accessible :day, :close_hour, :close_minute, :open_hour, :open_minute, :open_time, :close_time

  # === Associations
  belongs_to :target, :polymorphic => true, touch: true

  # === Validations
  validates :open_hour, :inclusion => 0..23
  validates :close_hour, :inclusion => 0..23
  validates :open_minute, :inclusion => 0..59
  validates :close_minute, :inclusion => 0..59
  validate do |record|
    total_opening_time = record.floor_total_opening_time_in_hours
    if total_opening_time < 0
      record.errors["open_time"] << "The opening hour must occur before the closing hour."
    elsif total_opening_time < record.minimum_booking_hours
      record.errors["close_time"] << "must be opened for at least #{sprintf('%.2f', record.minimum_booking_hours)} #{'hour'.pluralize(record.minimum_booking_hours)}"
    end
  end

  # === Callbacks
  before_validation :apply_default_minutes

  # Return a list of predefined availability rule templates
  def self.templates
    AvailabilityTemplate.all || []
  end

  def self.default_template
    templates[0]
  end

  def days=(days_array)
    super(days_array.select(&:present?)) if days_array
  end

  def minimum_booking_hours
    if target.respond_to?(:minimum_booking_minutes)
      @minimum_booking_hours ||= (target.minimum_booking_minutes/60.0)
    else
      1
    end
  end

  def open_time
    "#{open_hour}:#{"%02d" % open_minute}" if open_hour && open_minute
  end

  def open_time=(time)
    self.open_hour, self.open_minute = time.to_s.split(':')
  end

  def close_time
    "#{close_hour}:#{"%02d" % close_minute}" if close_hour && close_minute
  end

  def close_time=(time)
    self.close_hour, self.close_minute = time.to_s.split(':')
  end

  # Returns whether or not this availability rule is 'open' at a given hour & minute
  def open_at?(hour, minute)
    after_opening = hour > open_hour || open_hour == hour && minute >= open_minute
    before_closing = hour < close_hour || close_hour == hour && minute <= close_minute
    after_opening && before_closing
  end

  def day_open_minute
    open_hour * 60 + open_minute
  end

  def day_close_minute
    close_hour * 60 + close_minute
  end

  def open_time_with_default
    open_hour && open_minute ? open_time : "9:00"
  end

  def close_time_with_default
    close_hour && close_minute ? close_time : "17:00"
  end

  def floor_total_opening_time_in_hours
    (close_time_minus_open_time_in_minutes/60).floor
  end

  def close_time_minus_open_time_in_minutes
    day_close_minute - day_open_minute
  end

  def self.xml_attributes
    [:day, :open_hour, :open_minute, :close_hour, :close_minute, :days]
  end

  private

  def apply_default_minutes
    self.open_minute ||= 0
    self.close_minute ||= 0
  end
end
