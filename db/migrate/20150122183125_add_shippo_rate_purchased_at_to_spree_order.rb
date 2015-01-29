class AddShippoRatePurchasedAtToSpreeOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :shippo_rate_purchased_at, :datetime
  end
end
