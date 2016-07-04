class AddTransactablePricingIdToRecurringBookings < ActiveRecord::Migration
  def change
    add_column :recurring_bookings, :transactable_pricing_id, :integer
  end
end
