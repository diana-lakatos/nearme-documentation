class AddPermissionPagesToInstanceAdminRole < ActiveRecord::Migration

  class InstanceAdminRole < ActiveRecord::Base
  end

  def change
    add_column :instance_admin_roles, :permission_pages, :boolean, :default => true

    administrator_role = InstanceAdminRole.find_by_name 'Administrator'
    if administrator_role
      administrator_role.permission_pages = true
      administrator_role.save!
    end
  end
end
