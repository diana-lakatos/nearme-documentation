class CreateInstanceAdminPermissions < ActiveRecord::Migration

  class InstanceAdminRole < ActiveRecord::Base
  end

  def up
    create_table :instance_admins do |t|
      t.integer :user_id
      t.integer :instance_id
      t.integer :instance_admin_role_id
      t.boolean :instance_owner, :default => false
      t.timestamps
    end
    add_index :instance_admins, :user_id
    add_index :instance_admins, :instance_id
    add_index :instance_admins, :instance_admin_role_id

    create_table :instance_admin_roles do |t|
      t.string :name
      t.integer :instance_id
      t.boolean :permission_settings, :default => false
      t.boolean :permission_theme, :default => false
      t.boolean :permission_transfers, :default => false
      t.boolean :permission_inventories, :default => false
      t.boolean :permission_partners, :default => false
      t.boolean :permission_users, :default => false
      t.boolean :permission_analytics, :default => true
      t.timestamps
    end
    add_index :instance_admin_roles, :instance_id

    administrator = InstanceAdminRole.new
    administrator.name = 'Administrator'
    administrator.instance_id = nil
    administrator.permission_settings = true
    administrator.permission_theme = true
    administrator.permission_transfers = true
    administrator.permission_inventories = true
    administrator.permission_partners = true
    administrator.permission_users = true
    administrator.save!

    default = InstanceAdminRole.new
    default.name = 'Default'
    default.instance_id = nil
    default.save!
  end

  def down
    drop_table :instance_admins
    drop_table :instance_admin_roles
  end
end
