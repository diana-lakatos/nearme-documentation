class AddReservationTypeIdToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :reservation_type_id, :integer
    add_column :bids, :reservation_type_id, :integer
    add_column :reservations, :reservation_type_id, :integer
  end
end
