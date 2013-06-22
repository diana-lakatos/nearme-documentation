class DefaultValueForConfirmReservationsOnListings < ActiveRecord::Migration
  class Listing < ActiveRecord::Base
  end

  def up
    Listing.where('confirm_reservations is null').update_all(:confirm_reservations => false)
    change_column :listings, :confirm_reservations, :boolean, :null => false, :default => true
  end

  def down
    change_column :listings, :confirm_reservations, :boolean
  end
end
