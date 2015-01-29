class AddPrecalculatedCostToSpreeShippingMethod < ActiveRecord::Migration
  def change
    add_column :spree_shipping_methods, :precalculated_cost, :decimal,:precision => 8, :scale => 2
  end
end
