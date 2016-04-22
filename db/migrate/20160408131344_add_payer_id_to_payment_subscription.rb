class AddPayerIdToPaymentSubscription < ActiveRecord::Migration
  def change
    add_column :payment_subscriptions, :payer_id, :integer, index: true
  end
end
