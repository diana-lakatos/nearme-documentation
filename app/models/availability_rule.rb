class AvailabilityRule < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :day, :close_hour, :close_minute, :open_hour, :open_minute, :open_time, :close_time

  # === Associations
  belongs_to :target, :polymorphic => true, inverse_of: :availability_rules

  # === Validations
  validates :day, :inclusion => 0..6
  validates :open_hour, :inclusion => 0..23
  validates :close_hour, :inclusion => 0..23
  validates :open_minute, :inclusion => 0..59
  validates :close_minute, :inclusion => 0..59
  validates_each :day do |record, attr, value|
    total_opening_time = record.floor_total_opening_time_in_hours
    if total_opening_time < 0
      record.errors["day_#{value}"] << "The opening hour must occur before the closing hour."
    elsif total_opening_time < 1
      record.errors["day_#{value}"] << "must be opened for at least 1 hour"
    end
  end

  # === Callbacks
  before_validation :apply_default_minutes

  # Predefined availability templates
  TEMPLATES = [
    Template.new(:id => 'M-F9-5', :name => "Working Week", :days => 1..5, :hours => 9..17, :description => "Mon - Fri, 9:00 AM - 5:00 PM")
  ]

  # Return a list of predefined availability rule templates
  def self.templates
    TEMPLATES
  end

  def self.default_template
    templates[0]
  end

  def day_name
    Date::DAYNAMES[day]
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
    open_hour*60+open_minute
  end

  def day_close_minute
    close_hour*60+close_minute
  end

  def floor_total_opening_time_in_hours
    (close_time_minus_open_time_in_minutes/60).floor
  end

  def close_time_minus_open_time_in_minutes
    ((self.close_hour*60 + self.close_minute) - (self.open_hour*60 + self.open_minute))
  end

  def self.xml_attributes
    [:day, :open_hour, :open_minute, :close_hour, :close_minute]
  end

  private

  def apply_default_minutes
    self.open_minute ||= 0
    self.close_minute ||= 0
  end
end
