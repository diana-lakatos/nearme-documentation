class AddUniqueIndexForUsers < ActiveRecord::Migration
  def up
    add_index :users, [:instance_id, :email], unique: true, where: '(external_id IS NULL AND deleted_at IS NULL)'
  end

  def down
    remove_index :users, [:instance_id, :email]
  end
end
