class ReservationPeriod < ActiveRecord::Base
  belongs_to :reservation

  validates :date, :presence => true
  validate :validate_start_end_times

  attr_accessible :date, :start_minute, :end_minute

  delegate :listing, :to => :reservation

  # Returns the number of hours reserved on this date.
  # If no hourly time spefified, it is assumed that the reservation is for all open
  # hours of that booking.
  def hours
    if start_minute && end_minute
      (end_minute - start_minute) / 60.0
    else
      0
    end
  end

  def start_minute
    super || listing.availability.open_minute_for(date)
  end

  def end_minute
    super || listing.availability.close_minute_for(date)
  end

  def bookable?
    listing.available_on?(date, reservation.quantity, self[:start_minute], self[:end_minute])
  end

  def as_formatted_string
    date.strftime '%B %-d %Y'
  end

  private

  def validate_start_end_times
    start_minute, end_minute = self[:start_minute], self[:end_minute]
    return unless start_minute || end_minute

    unless start_minute && end_minute && start_minute < end_minute
      errors.add(:base, "Booking start and end times are invalid")
    end
  end
end
