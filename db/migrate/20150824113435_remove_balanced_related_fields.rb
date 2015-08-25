class RemoveBalancedRelatedFields < ActiveRecord::Migration
  def up
    remove_column :instance_clients, :encrypted_balanced_user_id
    remove_column :instances, :encrypted_live_balanced_api_key
    remove_column :instances, :encrypted_test_balanced_api_key
  end

  def down
    add_column :instance_clients, :encrypted_balanced_user_id, :string
    add_column :instances, :encrypted_live_balanced_api_key, :string
    add_column :instances, :encrypted_test_balanced_api_key, :string
  end
end
