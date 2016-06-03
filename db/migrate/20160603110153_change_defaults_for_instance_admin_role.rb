class ChangeDefaultsForInstanceAdminRole < ActiveRecord::Migration
  def self.up
    change_column_default :instance_admin_roles, :permission_analytics, false
  end

  def self.down
    change_column_default :instance_admin_roles, :permission_analytics, true
  end
end
