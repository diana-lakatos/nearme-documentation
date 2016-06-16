class CreateGroupMembers < ActiveRecord::Migration
  def change
    create_table :group_members do |t|
      t.integer :instance_id
      t.integer :user_id
      t.integer :group_id
      t.string  :email
      t.boolean :moderator, default: false
      t.datetime :approved_by_owner_at
      t.datetime :approved_by_user_at
      t.datetime :deleted_at
      t.timestamps null: false
    end

    add_index :group_members, :instance_id
    add_index :group_members, :user_id
    add_index :group_members, :group_id
  end
end
