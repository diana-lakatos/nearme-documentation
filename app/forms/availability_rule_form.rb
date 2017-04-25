# frozen_string_literal: true
class AvailabilityRuleForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  property :id
  property :_destroy, virtual: true

  property :open_time
  property :close_time
  property :days

  validates :open_time, presence: true
  validates :close_time, presence: true
  validates :days, presence: true

  validate :open_time_after_close_time

  def open_time_after_close_time
    errors.add(:close_time, I18n.t('errors.messages.open_time_before_close_time')) if opening_time.negative?
  end

  def days=(days)
    super(days.reject(&:blank?))
  end

  def opening_time
    return 0 if parsed_open_time.blank? || parsed_close_time.blank?
    @opening_time ||= (parsed_close_time - parsed_open_time) / 60
  end

  def parsed_open_time
    Time.zone.parse(open_time)
  rescue
    errors.add(:open_time, :invalid)
  end

  def parsed_close_time
    Time.zone.parse(close_time)
  rescue
    errors.add(:close_time, :invalid)
  end

  def validate_minimum_opening_times(booking_minutes)
    hours = booking_minutes.to_f / 60
    if opening_time < booking_minutes.to_i
      errors.add :close_time, I18n.t('errors.messages.minimum_open_time',
                                     minimum_hours: sprintf('%.2f', hours),
                                     count: hours)
      false
    else
      true
    end
  end
end
