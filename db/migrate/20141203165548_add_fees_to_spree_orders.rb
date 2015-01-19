class AddFeesToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :service_fee_buyer_percent, :integer, default: 0
    add_column :spree_orders, :service_fee_seller_percent, :integer, default: 0
  end
end
