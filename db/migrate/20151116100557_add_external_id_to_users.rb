class AddExternalIdToUsers < ActiveRecord::Migration
  def up
    add_column :users, :external_id, :string, default: nil
    remove_index :users, name: "index_users_on_slug"
    add_index :users, [:instance_id, :email, :external_id], unique: true, where: '(deleted_at IS NULL)'
  end

  def down
    remove_column :users, :external_id
    add_index :users, [:instance_id, :email], unique: true, where: '(deleted_at IS NULL)', name: 'index_users_on_slug'
  end
end
