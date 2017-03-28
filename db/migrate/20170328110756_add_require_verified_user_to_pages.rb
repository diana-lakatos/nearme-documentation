class AddRequireVerifiedUserToPages < ActiveRecord::Migration
  def change
    add_column :pages, :require_verified_user, :boolean, default: false
  end
end
