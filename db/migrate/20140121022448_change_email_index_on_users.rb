class ChangeEmailIndexOnUsers < ActiveRecord::Migration
  def up
    remove_index :users, :email
    add_index :users, :email, unique: true, where: '(deleted_at IS NULL)'
    add_index :users, :deleted_at
  end

  def down
    remove_index :users, :email
    remove_index :users, :deleted_at
    add_index :users, :email
  end
end
