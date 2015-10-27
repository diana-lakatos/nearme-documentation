class AddActiveStateToPaymentGateways < ActiveRecord::Migration
  def change
    add_column :payment_gateways, :test_active, :boolean
    add_column :payment_gateways, :live_active, :boolean
  end
end
