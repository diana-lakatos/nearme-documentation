class PopulateArchivedAtForReservations < ActiveRecord::Migration
  def up
    puts "Marked #{Reservation.where('reservations.ends_at < ? OR reservations.state IN (?)', Time.current, ['rejected', 'expired', 'cancelled_by_host', 'cancelled_by_guest']).update_all(archived_at: Time.zone.now)} as archived"
  end

  def down
  end
end
