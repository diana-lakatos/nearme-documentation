class AddAutheticationIdToUserRelationships < ActiveRecord::Migration
  def change
    add_column :user_relationships, :authentication_id, :integer, references: :authentications
    add_index :user_relationships, :authentication_id
  end
end
