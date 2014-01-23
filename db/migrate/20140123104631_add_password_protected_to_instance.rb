class AddPasswordProtectedToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :password_protected, :boolean, default: false
    add_column :instances, :encrypted_marketplace_password, :string
  end
end
