class AddPermissionProjectsToInstanceAdminRoles < ActiveRecord::Migration
  def up
    add_column :instance_admin_roles, :permission_projects, :boolean, default: false
    InstanceAdminRole.administrator_role.try(:update_column, :permission_projects, true)
  end

  def down
    remove_column :instance_admin_roles, :permission_projects
  end
end
