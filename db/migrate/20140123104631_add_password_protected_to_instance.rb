class AddPasswordProtectedToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :encrypted_marketplace_password, :string
  end
end
