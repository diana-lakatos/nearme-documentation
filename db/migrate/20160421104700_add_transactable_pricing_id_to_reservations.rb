class AddTransactablePricingIdToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :transactable_pricing_id, :integer
  end
end
