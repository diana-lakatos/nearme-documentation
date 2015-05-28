class AddSearchableToSpreeProductTypes < ActiveRecord::Migration
  def change
    add_column :spree_product_types, :searchable, :boolean, default: true
  end
end