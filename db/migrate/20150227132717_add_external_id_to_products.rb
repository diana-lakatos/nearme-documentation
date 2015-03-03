class AddExternalIdToProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :external_id, :string

    add_index :spree_products, [:external_id, :company_id], unique: true
  end
end
