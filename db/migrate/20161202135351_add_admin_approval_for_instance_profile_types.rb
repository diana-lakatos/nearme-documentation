class AddAdminApprovalForInstanceProfileTypes < ActiveRecord::Migration
  def change
    add_column :instance_profile_types, :admin_approval, :boolean, default: false, null: false
  end
end
