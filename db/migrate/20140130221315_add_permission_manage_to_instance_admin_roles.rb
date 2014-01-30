class AddPermissionManageToInstanceAdminRoles < ActiveRecord::Migration

  class InstanceAdminRole < ActiveRecord::Base
  end

  def change
    add_column :instance_admin_roles, :permission_manage, :boolean, :default => false
    remove_column :instance_admin_roles, :permission_users
    remove_column :instance_admin_roles, :permission_pages
    remove_column :instance_admin_roles, :permission_transfers
    remove_column :instance_admin_roles, :permission_inventories
    remove_column :instance_admin_roles, :permission_partners

    administrator_role = InstanceAdminRole.find_by_name 'Administrator'
    if administrator_role
      administrator_role.permission_manage = true
      administrator_role.save!
    end
  end
end
