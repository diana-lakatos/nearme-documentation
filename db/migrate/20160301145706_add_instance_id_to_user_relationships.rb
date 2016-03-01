class AddInstanceIdToUserRelationships < ActiveRecord::Migration
  def change
    add_column :user_relationships, :instance_id, :integer
    add_column :domains, :instance_id, :integer
    add_column :themes, :instance_id, :integer
  end
end
