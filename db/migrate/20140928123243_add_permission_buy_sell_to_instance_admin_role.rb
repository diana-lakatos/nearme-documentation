class AddPermissionBuySellToInstanceAdminRole < ActiveRecord::Migration
  def up
    add_column :instance_admin_roles, :permission_buysell, :boolean, default: false

    administrator_instance_role = InstanceAdminRole.where('instance_id IS NULL AND name = ?', 'Administrator').first
    if administrator_instance_role
      administrator_instance_role.update_column(:permission_buysell, true)
    end
  end

  def down
    remove_column :instance_admin_roles, :permission_buysell
  end
end
