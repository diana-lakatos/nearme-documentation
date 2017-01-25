class AddPaymentSourceToPayments < ActiveRecord::Migration

  def change
    add_column :payments, :payment_source_id, :integer
    add_column :payments, :payment_source_type, :string

    Payment.reset_column_information
    Payment.update_all("payment_source_type = 'CreditCard'")
    Payment.update_all("payment_source_id = credit_card_id")
  end
end
