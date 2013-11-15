# Sends rating reminders at midday day after visit
class RatingReminderJob < Job

  def initialize(date_string)
    @date = Date.parse(date_string).yesterday
  end

  def perform
    reservations = Reservation.joins(:periods).confirmed.where('reservation_periods.date = ?', @date)
    reservations = reservations.where("request_guest_rating_email_sent_at IS NULL OR request_guest_rating_email_sent_at IS NULL")
    reservations = reservations.select do |reservation|
      reservation.last_date >= @date && reservation.location.local_time.hour == 12
    end
    reservations.each do |reservation|
      if reservation.request_guest_rating_email_sent_at.blank?
        RatingMailer.request_guest_rating(reservation).deliver
        reservation.update_column(:request_guest_rating_email_sent_at, Time.zone.now)
      end

      if reservation.request_host_rating_email_sent_at.blank?
        RatingMailer.request_host_rating(reservation).deliver
        reservation.update_column(:request_host_rating_email_sent_at, Time.zone.now)
      end
    end
  end
end
