class AddPermissionSupportToInstanceAdminRoles < ActiveRecord::Migration
  def change
    add_column :instance_admin_roles, :permission_support, :boolean, default: false
  end
end
