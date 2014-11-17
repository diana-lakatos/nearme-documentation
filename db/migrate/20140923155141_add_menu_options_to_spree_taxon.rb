class AddMenuOptionsToSpreeTaxon < ActiveRecord::Migration
  def change
    add_column :spree_taxons, :in_top_nav, :boolean, default: false
    add_column :spree_taxons, :top_nav_position, :integer

    add_index :spree_taxons, :in_top_nav
  end
end
