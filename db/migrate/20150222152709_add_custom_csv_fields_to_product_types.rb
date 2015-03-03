class AddCustomCsvFieldsToProductTypes < ActiveRecord::Migration
  def change
    add_column :spree_product_types, :custom_csv_fields, :text
  end
end
