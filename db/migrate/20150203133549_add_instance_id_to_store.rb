class AddInstanceIdToStore < ActiveRecord::Migration
  def change
    add_column :spree_stores, :instance_id, :integer
    add_index :spree_stores, :instance_id
  end
end
