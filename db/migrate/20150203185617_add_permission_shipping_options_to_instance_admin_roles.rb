class AddPermissionShippingOptionsToInstanceAdminRoles < ActiveRecord::Migration
  def change
    add_column :instance_admin_roles, :permission_shippingoptions, :boolean, default: false
  end
end
