class AddMinimumBookingMinutesToListing < ActiveRecord::Migration
  def up
    connection.execute <<-SQL
      UPDATE transactables
      SET
        minimum_booking_minutes = tt.minimum_booking_minutes
      FROM transactable_types AS tt
      WHERE transactable_type_id = tt.id
    SQL
  end

  def down
  end
end
