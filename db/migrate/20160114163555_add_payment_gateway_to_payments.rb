class AddPaymentGatewayToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :state, :string
    add_column :payments, :payment_gateway_id, :integer
    add_column :payments, :payment_gateway_mode, :string
    add_index :payments, :payment_gateway_id
  end
end
