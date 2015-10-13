class AddSubscriptionBilling < ActiveRecord::Migration
  def change
    add_column :transactable_types, :action_subscription_booking, :boolean
    add_column :transactables, :action_subscription_booking, :boolean
    add_column :transactables, :weekly_subscription_price_cents, :integer
    add_column :transactables, :monthly_subscription_price_cents, :integer
  end
end
