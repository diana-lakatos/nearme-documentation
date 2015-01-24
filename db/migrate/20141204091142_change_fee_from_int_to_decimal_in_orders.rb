class ChangeFeeFromIntToDecimalInOrders < ActiveRecord::Migration
  def change
    change_column :spree_orders, :service_fee_buyer_percent, :decimal, :precision => 5, :scale => 2, :default => 0
    change_column :spree_orders, :service_fee_seller_percent, :decimal, :precision => 5, :scale => 2, :default => 0
  end
end
