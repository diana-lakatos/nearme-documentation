class AddExpiredAtToPaymentSubscription < ActiveRecord::Migration
  def change
    add_column :payment_subscriptions, :expired_at, :timestamp
  end
end
