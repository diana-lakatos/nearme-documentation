class AddCompiledNewDashboardStylesheetToTheme < ActiveRecord::Migration
  def change
    add_column :themes, :compiled_new_dashboard_stylesheet, :string
    add_column :themes, :theme_new_dashboard_digest, :string
  end
end
