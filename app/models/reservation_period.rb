class ReservationPeriod < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :reservation

  validates :date, :presence => true
  validate :validate_start_end_times

  # attr_accessible :date, :start_minute, :end_minute

  delegate :listing, :time_zone, :to => :reservation, allow_nil: true

  # Returns the number of hours reserved on this date.
  # If no hourly time specified, it is assumed that the reservation is for all open
  # hours of that booking.
  def hours
    minutes / 60.0
  end

  def minutes
    (end_minute || start_minute).to_i - start_minute.to_i
  end

  def start_minute
    super || listing.try { |l| l.availability.try(:open_minute_for, date) }
  end

  def end_minute
    super || listing.try { |l| l.availability.try(:close_minute_for, date) }
  end

  def bookable?
    listing.available_on?(date, reservation.quantity, self[:start_minute], self[:end_minute])
  end

  def as_formatted_string
    I18n.l(date, format: :long)
  end

  def date_with_time
    if listing.schedule_booking?
      Minute.new(start_minute, date).to_time.to_formatted_s(:db)
    else
      date.strftime('%Y-%m-%d')
    end
  end

  def starts_at
    Minute.new(start_minute.to_i, date).to_time_in_timezone(time_zone)
  end

  def ends_at
    Minute.new(end_minute || 1439, date).to_time_in_timezone(time_zone)
  end

  private

  def validate_start_end_times
    start_minute, end_minute = self[:start_minute], self[:end_minute]
    return unless start_minute || end_minute

    unless start_minute && end_minute && start_minute <= end_minute
      errors.add(:base, "Booking start and end times are invalid")
    end
  end
end
