class AddInsuranceEnabledToOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :insurance_enabled, :boolean, default: false, null: false
  end
end
