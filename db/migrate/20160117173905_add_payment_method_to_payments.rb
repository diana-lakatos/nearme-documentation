class AddPaymentMethodToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_method_id, :integer
    add_index :payments, :payment_method_id
  end
end
