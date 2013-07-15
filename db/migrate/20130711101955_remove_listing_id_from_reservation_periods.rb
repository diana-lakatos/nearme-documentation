class RemoveListingIdFromReservationPeriods < ActiveRecord::Migration
  def up
    remove_column(:reservation_periods, :listing_id)
  end

  def down
    add_column(:reservation_periods, :listing_id, :integer)
  end
end
