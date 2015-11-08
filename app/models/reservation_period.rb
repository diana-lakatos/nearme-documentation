class ReservationPeriod < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :reservation

  validates :date, :presence => true
  validate :validate_start_end_times

  # attr_accessible :date, :start_minute, :end_minute

  delegate :listing, :time_zone, :to => :reservation

  # Returns the number of hours reserved on this date.
  # If no hourly time specified, it is assumed that the reservation is for all open
  # hours of that booking.
  def hours
    if start_minute && end_minute
      (end_minute - start_minute) / 60.0
    else
      0
    end
  end

  def minutes
    if start_minute && end_minute
      (end_minute - start_minute)
    else
      0
    end
  end

  def start_minute
    super || listing.try { |l| l.availability.open_minute_for(date) }
  end

  def end_minute
    super || listing.try { |l| l.availability.close_minute_for(date) }
  end

  def bookable?
    listing.available_on?(date, reservation.quantity, self[:start_minute], self[:end_minute])
  end

  def as_formatted_string
    I18n.l(date, format: :long)
  end

  def date_with_time
    if listing.schedule_booking?
      hour = start_minute/60
      minute = start_minute - (60 * hour)
      Time.parse("#{date} #{hour}:#{minute}").to_formatted_s(:db)
    else
      date.strftime('%Y-%m-%d')
    end
  end

  def starts_at
    Time.use_zone time_zone do
      if start_minute
        Time.zone.parse("#{date} #{Time.at(start_minute.to_i * 60).utc.strftime("%H:%M:%S")}")
      else
        Time.zone.parse("#{date}").beginning_of_day
      end
    end
  end

  def ends_at
    Time.use_zone time_zone do
      if end_minute
        Time.zone.parse("#{date} #{Time.at(end_minute.to_i * 60).utc.strftime("%H:%M:%S")}")
      else
        Time.zone.parse("#{date}").end_of_day
      end
    end
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
