class AddDraftToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :draft, :boolean, default: false
  end
end
