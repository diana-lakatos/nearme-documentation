class AddShippoRateIdToShippingMethod < ActiveRecord::Migration
  def change
    add_column :spree_shipping_methods, :shippo_rate_id, :string, :limit => 230
  end
end
