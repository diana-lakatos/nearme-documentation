# frozen_string_literal: true
class ReservationPeriod < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  belongs_to :reservation
  belongs_to :old_reservation

  validates :date, presence: true
  validate :validate_start_end_times

  END_OF_DAY_MINUTES = 1439

  delegate :transactable, :time_zone, to: :reservation, allow_nil: true

  scope :recurring, -> { where.not(recurring_frequency: nil).where.not(recurring_frequency_unit: nil) }

  # @return [Float] the number of hours reserved on this date; if no hourly time specified,
  #   it is assumed that the reservation is for all open hours of that booking.
  def hours
    minutes / 60.0
  end

  def hours=(number)
    if self[:start_minute] && number.to_f.positive?
      # set end_time based on start_time and hours
      self[:end_minute] = self[:start_minute].to_i + number.to_f * 60
    elsif self[:start_minute].nil? || hours != number.to_f
      # sets start/end_minute to correct values when given hours don't match minutes
      # from start/end_minutes
      self.start_minute = 0 if self[:start_minute].blank?
      self.end_minute = self[:start_minute].to_i + number.to_f * 60
    end
  end

  def minutes
    (end_minute || start_minute).to_i - start_minute.to_i
  end

  def start_minute
    super || transactable.try { |l| l.availability.try(:open_minute_for, date) }
  end

  def end_minute
    super || transactable.try { |l| l.availability.try(:close_minute_for, date) }
  end

  def bookable?
    transactable.available_on?(date, reservation.quantity, self[:start_minute], self[:end_minute], is_recurring?)
  end

  def transactable_open_on?
    transactable.open_on?(date, self[:start_minute], self[:end_minute])
  end

  def as_formatted_string
    I18n.l(date, format: :long)
  end

  def date_with_time
    if transactable.event_booking?
      Minute.new(start_minute, date).to_time.to_formatted_s(:db)
    else
      date.strftime('%Y-%m-%d')
    end
  end

  def starts_at
    Minute.new(start_minute.to_i, date).to_time_in_timezone(time_zone)
  end

  def ends_at
    Minute.new(end_minute || END_OF_DAY_MINUTES, date).to_time_in_timezone(time_zone)
  end

  def is_recurring?
    recurring_frequency.to_i > 0 && recurring_frequency_unit.present?
  end

  def to_liquid
    @reservation_period_drop ||= ReservationPeriodDrop.new(decorate)
  end

  private

  def validate_start_end_times
    start_minute = self[:start_minute]
    end_minute = self[:end_minute]
    return unless start_minute || end_minute

    errors.add(:base, 'Booking start and end times are invalid') unless start_minute && end_minute && start_minute <= end_minute
  end
end
