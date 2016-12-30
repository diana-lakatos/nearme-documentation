class AddPaymentSourceToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_source_id, :integer
    add_column :payments, :payment_source_type, :string

    PaymentSource.reset_column_information
    PaymentSource.update_all("payment_source_type = 'CreditCard'")
    PaymentSource.update_all("payment_source_id = credit_card_id")
  end
end
