class AddQuantityToReservations < ActiveRecord::Migration
  class Reservation < ActiveRecord::Base
    has_many :periods, :class_name => 'AddQuantityToReservations::ReservationPeriod'
  end

  class ReservationPeriod < ActiveRecord::Base
    has_many :seats, :class_name => 'AddQuantityToReservations::ReservationSeat'
  end

  class ReservationSeat < ActiveRecord::Base
  end

  def up
    add_column :reservations, :quantity, :integer, :null => false, :default => 1

    Reservation.find_each do |reservation|
      reservation.transaction do
        # NB: All instances of production reservations only include a single quantity across all
        # dates, which is why we can do this retroactively.
        reservation.quantity = reservation.periods.map { |rp| rp.seats.count }.max || 1
        reservation.save!
      end
    end
  end

  def down
    remove_column :reservations, :quantity
  end
end
