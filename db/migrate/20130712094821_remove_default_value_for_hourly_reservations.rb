class RemoveDefaultValueForHourlyReservations < ActiveRecord::Migration
  def up
    # the only way to force proper migration: :default => nil, :null => true
    change_column(:listings, :hourly_reservations, :boolean, :default => nil, :null => true)
  end

  def down
    change_column(:listings, :hourly_reservations, :boolean, :default => false, :null => true)
  end
end
