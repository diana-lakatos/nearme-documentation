class RemoveCreditCardIdFromPayments < ActiveRecord::Migration
  def change
    rename_column :payments, :credit_card_id, :credit_card_id_old
    rename_column :payment_subscriptions, :credit_card_id, :credit_card_id_old
  end
end
