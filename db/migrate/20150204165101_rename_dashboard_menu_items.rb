class RenameDashboardMenuItems < ActiveRecord::Migration
  def change
    rename_column :instances, :hidden_dashboard_menu_items, :hidden_ui_controls
  end
end
