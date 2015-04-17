class AddMultipleRootCategriesToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :multiple_root_categries, :boolean
    remove_column :transactable_types, :multiple_root_categries, :boolean
  end
end
