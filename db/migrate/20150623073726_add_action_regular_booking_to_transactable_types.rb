class AddActionRegularBookingToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :action_regular_booking, :boolean, default: true
  end
end
