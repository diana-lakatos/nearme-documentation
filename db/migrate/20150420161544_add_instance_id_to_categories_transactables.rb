class AddInstanceIdToCategoriesTransactables < ActiveRecord::Migration
  def change
    add_column :categories_transactables, :instance_id, :integer
    add_index :categories_transactables, :instance_id
  end
end
