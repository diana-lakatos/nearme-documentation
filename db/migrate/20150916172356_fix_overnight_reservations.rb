class FixOvernightReservations < ActiveRecord::Migration
  def up
    Transactable.unscoped.where(booking_type: "overnight").joins(:reservations).uniq.find_each do |transactable|
      transactable.instance.set_context!
      transactable.reservations.find_each do |reservation|
        last_period = reservation.periods.order("date ASC").last
        reservation.add_period(last_period.date + 1.day)
        reservation.save!
      end
    end
  end
end
