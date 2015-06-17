class AddPaymentGatewayIdToPaymentTransfers < ActiveRecord::Migration
  def change
    add_column :payment_transfers, :payment_gateway_id, :integer, index: true
  end
end
