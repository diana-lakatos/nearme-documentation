class AddRequireVerifiedUserToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :require_verified_user, :boolean, default: false
  end
end
