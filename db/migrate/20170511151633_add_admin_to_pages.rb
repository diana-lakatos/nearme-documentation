class AddAdminToPages < ActiveRecord::Migration
  def change
    add_column :pages, :admin_page, :boolean, default: false
  end
end
