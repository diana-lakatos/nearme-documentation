class AddConfigToPaymentGateways < ActiveRecord::Migration
  def change
    add_column :payment_gateways, :config, :text
  end
end
