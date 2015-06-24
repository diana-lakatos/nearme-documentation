class AddActionContinuousDatesBookingToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :action_continuous_dates_booking, :boolean, default: false
  end
end
