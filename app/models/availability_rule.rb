class AvailabilityRule < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid
  # attr_accessible :day, :close_hour, :close_minute, :open_hour, :open_minute, :open_time, :close_time

  # === Associations
  belongs_to :target, polymorphic: true, touch: true
  belongs_to :instance
  attr_accessor :skip_time_validation

  # === Validations
  validate do |record|
    unless skip_time_validation
      total_opening_time = record.floor_total_opening_time_in_hours
      record.errors.add :open_time, I18n.t('errors.messages.blank') if day_open_minute.nil?
      record.errors.add :close_time, I18n.t('errors.messages.blank') if day_close_minute.nil?
      if total_opening_time.present?
        if total_opening_time < 0
          record.errors.add :base, I18n.t('errors.messages.open_time_before_close_time')
        elsif total_opening_time < record.minimum_booking_hours
          record.errors.add :base, I18n.t('errors.messages.minimum_open_time', minimum_hours: sprintf('%.2f', record.minimum_booking_hours), count: record.minimum_booking_hours)
        end
      end
    end
  end

  # === Callbacks
  before_validation :apply_default_minutes
  after_save :update_location

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
      @minimum_booking_hours ||= (target.minimum_booking_minutes / 60.0)
    else
      1
    end
  end

  def open_time
    "#{open_hour}:#{'%02d' % open_minute}" if open_hour && open_minute
  end

  def open_time=(time)
    self.open_hour, self.open_minute = date_time_handler.convert_to_time(time).strftime('%H:%M').split(':')
  rescue
    self.open_hour = nil
    self.open_minute = nil
  end

  def close_time
    "#{close_hour}:#{'%02d' % close_minute}" if close_hour && close_minute
  end

  def close_time=(time)
    self.close_hour, self.close_minute = date_time_handler.convert_to_time(time).strftime('%H:%M').split(':')
  rescue
    self.close_hour = nil
    self.close_minute = nil
  end

  # Returns whether or not this availability rule is 'open' at a given hour & minute
  def open_at?(hour, minute)
    after_opening = hour > open_hour || open_hour == hour && minute >= open_minute
    before_closing = hour < close_hour || close_hour == hour && minute <= close_minute
    after_opening && before_closing
  end

  def day_open_minute
    open_hour * 60 + open_minute rescue nil
  end

  def day_close_minute
    close_hour * 60 + close_minute rescue nil
  end

  def open_time_with_default
    open_hour && open_minute ? open_time : nil
  end

  def close_time_with_default
    close_hour && close_minute ? close_time : nil
  end

  def floor_total_opening_time_in_hours
    (close_time_minus_open_time_in_minutes / 60).floor rescue nil
  end

  def close_time_minus_open_time_in_minutes
    day_close_minute - day_open_minute rescue nil
  end

  def self.xml_attributes
    [:day, :open_hour, :open_minute, :close_hour, :close_minute, :days]
  end

  def to_liquid
    @availability_rule_drop ||= AvailabilityRuleDrop.new(self)
  end

  private

  def update_location
    if changed? && target.try(:parent_type) == 'Location'
      target.parent.update_open_hours
    end
  end

  def apply_default_minutes
    self.open_minute ||= 0
    self.close_minute ||= 0
  end

  def date_time_handler
    @date_time_handler ||= DateTimeHandler.new
  end
end
