class AddBrowserDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :browser, :string
    add_column :users, :browser_version, :string
    add_column :users, :platform, :string
  end
end
