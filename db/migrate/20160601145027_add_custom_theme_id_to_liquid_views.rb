class AddCustomThemeIdToLiquidViews < ActiveRecord::Migration
  def change
    add_column :instance_views, :custom_theme_id, :integer, index: true
  end
end
