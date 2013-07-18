class AddDeletedAtToReservationCharges < ActiveRecord::Migration
  def change
    add_column :reservation_charges, :deleted_at, :datetime
  end
end
