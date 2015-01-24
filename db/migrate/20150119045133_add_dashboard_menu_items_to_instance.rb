class AddDashboardMenuItemsToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :hidden_dashboard_menu_items, :text
  end
end
