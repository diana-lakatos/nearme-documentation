class RemoveCreditCardIdFromPayments < ActiveRecord::Migration
  def change
    remove_column :payments, :credit_card_id, :integer
    remove_column :payment_subscriptions, :credit_card_id, :integer
  end
end
