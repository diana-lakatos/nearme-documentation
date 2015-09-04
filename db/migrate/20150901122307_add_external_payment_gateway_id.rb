class AddExternalPaymentGatewayId < ActiveRecord::Migration
  def change
    add_column :payments, :external_transaction_id, :string, index: true
  end
end
