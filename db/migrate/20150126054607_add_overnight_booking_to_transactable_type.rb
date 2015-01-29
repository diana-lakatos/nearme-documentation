class AddOvernightBookingToTransactableType < ActiveRecord::Migration
  def change
    add_column :transactable_types, :overnight_booking, :boolean, null: false, default: false
  end
end
