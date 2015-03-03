class AddManualPaymentToProductTypesAndProducts < ActiveRecord::Migration
  def change
    add_column :spree_product_types, :possible_manual_payment, :boolean
    add_column :spree_products, :possible_manual_payment, :boolean
  end
end
