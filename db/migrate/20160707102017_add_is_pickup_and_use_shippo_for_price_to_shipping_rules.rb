class AddIsPickupAndUseShippoForPriceToShippingRules < ActiveRecord::Migration
  def change
    add_column :shipping_rules, :is_pickup, :boolean
    add_column :shipping_rules, :use_shippo_for_price, :boolean
  end
end
