class AddFieldsToSpreeShippingMethods < ActiveRecord::Migration
  def up
    add_column :spree_shipping_methods, :processing_time, :string
  end

  def down
    remove_column :spree_shipping_methods, :processing_time
  end
end
