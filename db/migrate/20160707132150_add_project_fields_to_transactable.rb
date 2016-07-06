class AddProjectFieldsToTransactable < ActiveRecord::Migration
  def change
    add_column :transactables, :seek_collaborators, :boolean, default: false
    add_column :transactables, :followers_count, :integer, null: false, default: 0
  end
end
