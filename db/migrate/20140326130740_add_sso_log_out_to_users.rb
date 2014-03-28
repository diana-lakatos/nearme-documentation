class AddSsoLogOutToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sso_log_out, :boolean, default: false
  end
end
