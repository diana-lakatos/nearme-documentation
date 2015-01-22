class AddCompiledDashboardStylesheetToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :compiled_dashboard_stylesheet, :string
  end
end
