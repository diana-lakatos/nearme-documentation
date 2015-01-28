class AddShippoRateResultInfoToShippingMethod < ActiveRecord::Migration
  def change
    add_column :spree_shipping_methods, :shippo_label_url, :text
    add_column :spree_shipping_methods, :shippo_tracking_number, :text
  end
end
