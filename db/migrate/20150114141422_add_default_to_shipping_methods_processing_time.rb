class AddDefaultToShippingMethodsProcessingTime < ActiveRecord::Migration
  def change
    change_column :spree_shipping_methods, :processing_time, :integer, default: 0
  end
end
