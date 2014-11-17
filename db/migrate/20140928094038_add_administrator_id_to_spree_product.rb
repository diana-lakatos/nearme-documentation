class AddAdministratorIdToSpreeProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :administrator_id, :integer
  end
end
