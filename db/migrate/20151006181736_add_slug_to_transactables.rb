class AddSlugToTransactables < ActiveRecord::Migration
  def up
    add_column :transactables, :slug, :string
    add_index :transactables, :slug

    add_column :transactable_types, :slug, :string
    add_index :transactable_types, :slug
  end

  def down
    remove_column :transactables, :slug
    remove_column :transactable_types, :slug
  end
end
