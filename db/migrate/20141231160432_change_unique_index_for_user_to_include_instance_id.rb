class ChangeUniqueIndexForUserToIncludeInstanceId < ActiveRecord::Migration
  def up
    remove_index :users, "email"
    remove_index :users, "slug"
    remove_index :users, "reset_password_token"

    add_index :users, [:instance_id, :slug], unique: true, name: "index_users_on_email"
    add_index :users, [:instance_id, :email], unique: true, where: '(deleted_at IS NULL)', name: 'index_users_on_slug'
    add_index :users, [:instance_id, :reset_password_token], name: "index_users_on_reset_password_token", unique: true

    add_column :users, :banned_at, :datetime, default: nil
    add_column :users, :instance_profile_type_id, :integer
    add_index :users, :instance_profile_type_id
    add_column :users, :properties, :hstore

    add_column :users, :reservations_count, :integer, default: 0
    add_column :users, :transactables_count, :integer, default: 0

    connection.execute <<-SQL
      UPDATE users as u
      SET banned_at = b.created_at
      FROM user_bans b
      WHERE b.user_id = u.id AND b.instance_id = u.instance_id
    SQL

    connection.execute <<-SQL
      UPDATE users as u
      SET instance_profile_type_id = p.instance_profile_type_id,
        properties = p.properties,
        reservations_count = p.reservations_count,
        transactables_count = p.transactables_count
      FROM user_instance_profiles p
      WHERE p.user_id = u.id
    SQL

    connection.execute <<-SQL
      UPDATE users as u
      SET instance_profile_type_id = 1
      WHERE u.instance_profile_type_id is NULL
    SQL

  end

  def down
    remove_index :users, "email"
    remove_index :users, "slug"
    remove_index :users, "reset_password_token"
    add_index :users, :slug, unique: true
    add_index :users, :email, unique: true, where: '(deleted_at IS NULL)'
    add_index :users, :reset_password_token, unique: true
    remove_column :users, :banned_at
    remove_column :users, :instance_profile_type_id
    remove_column :users, :properties
    remove_column :users, :reservations_count
    remove_column :users, :transactables_count
  end
end
