class AddPermissionGroupsToInstanceAdminRoles < ActiveRecord::Migration
  def up
    add_column :instance_admin_roles, :permission_groups, :boolean, default: false
    InstanceAdminRole.administrator_role.try(:update_column, :permission_groups, true)
  end

  def down
    remove_column :instance_admin_roles, :permission_groups
  end
end
