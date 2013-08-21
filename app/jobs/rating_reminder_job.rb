# Sends rating reminders at midday day after visit
class RatingReminderJob < Job

  def initialize(date_string)
    @date = Date.parse(date_string).yesterday
  end

  def perform
    reservations = Reservation.joins(:periods).where('reservation_periods.date = ?', @date)
    reservations = reservations.select do |reservation|
      reservation.last_date == @date && reservation.location.local_time.hour == 12
    end
    reservations.each do |reservation|
      RatingMailer.request_guest_rating(reservation).deliver
      RatingMailer.request_host_rating(reservation).deliver
    end
  end
end
