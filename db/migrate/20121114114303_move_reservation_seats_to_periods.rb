class MoveReservationSeatsToPeriods < ActiveRecord::Migration
  class ReservationSeat < ActiveRecord::Base
  end

  class ReservationPeriod < ActiveRecord::Base
  end

  def up
    rename_column :reservation_seats, :reservation_id, :reservation_period_id

    ReservationSeat.find_each do |reservation_seat|
      # NB: Column renamed, but still has reservation id
      reservation_periods = ReservationPeriod.where(:reservation_id => reservation_seat.reservation_period_id).all
      unless reservation_periods.present?
        puts "Deleting ReservationSeat##{reservation_seat.id} as no reservation period"
        reservation_seat.delete
        next
      end

      first_period = reservation_periods.shift
      reservation_seat.reservation_period_id = first_period.id
      reservation_seat.save!
      puts "Moved ReservationSeat##{reservation_seat.id} to ReservationPeriod##{first_period.id}"

      # Copy to other periods (if any)
      reservation_periods.each do |reservation_period|
        ReservationSeat.create!(
          :reservation_period_id => reservation_period.id,
          :user_id => reservation_seat.user_id,
          :name    => reservation_seat.name,
          :email   => reservation_seat.email
        )
        puts "Copied ReservationSeat##{reservation_seat.id} to ReservationPeriod##{reservation_period.id}"
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
