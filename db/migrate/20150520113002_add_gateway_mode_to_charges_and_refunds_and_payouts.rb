class AddGatewayModeToChargesAndRefundsAndPayouts < ActiveRecord::Migration
  def change
    add_column :charges, :payment_gateway_mode, :string, limit: 4
    add_column :refunds, :payment_gateway_mode, :string, limit: 4
    add_column :payouts, :payment_gateway_mode, :string, limit: 4
    add_column :payment_transfers, :payment_gateway_mode, :string, limit: 4
  end
end
