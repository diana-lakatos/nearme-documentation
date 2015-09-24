class AddReportsToInstanceAdminRoles < ActiveRecord::Migration
  def change
    add_column :instance_admin_roles, :permission_reports, :boolean, default: false
  end
end
