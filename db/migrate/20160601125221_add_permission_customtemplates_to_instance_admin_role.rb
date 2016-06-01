class AddPermissionCustomtemplatesToInstanceAdminRole < ActiveRecord::Migration
  def change
    add_column :instance_admin_roles, :permission_customtemplates, :boolean, default: true
  end
end
