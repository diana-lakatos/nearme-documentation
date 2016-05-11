class FixExpireAtForReservations < ActiveRecord::Migration
  def up
    Reservation.where(expires_at:nil).where.not(state: 'inactive').joins(:listing).find_each do |res|
      puts "Reservation #{res.id} fixed"
      res.update_column(:expires_at, res.created_at + res.listing.hours_to_expiration.to_i.hours)
    end

    Reservation.where(expires_at:nil).where.not(state: 'inactive').find_each do |res|
      puts "Reservation #{res.id} fixed"
      res.update_column(:expires_at, res.created_at + 24.hours)
    end
  end

  def down
  end
end
