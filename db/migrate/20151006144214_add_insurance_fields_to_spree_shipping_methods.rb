class AddInsuranceFieldsToSpreeShippingMethods < ActiveRecord::Migration
  def change
    add_column :spree_shipping_methods, :insurance_amount, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :spree_shipping_methods, :insurance_currency, :string
  end
end
