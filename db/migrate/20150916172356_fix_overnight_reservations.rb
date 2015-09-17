class FixOvernightReservations < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      i.set_context!
      Transactable.with_deleted.where(booking_type: "overnight").joins(:reservations).uniq.find_each do |transactable|
        transactable.reservations.find_each do |reservation|
          last_period = reservation.periods.order("date DESC").first
          reservation.add_period(last_period.date + 1.day)
          reservation.save!
        end
      end
    end
  end
end
