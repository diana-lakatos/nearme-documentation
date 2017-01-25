class AddPaymentSourceToPaymentSubscription < ActiveRecord::Migration
  def change
    add_column :payment_subscriptions, :payment_source_type, :string
    add_column :payment_subscriptions, :payment_source_id, :integer
  end
end
