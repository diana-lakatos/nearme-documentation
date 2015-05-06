class AddCssDigestsToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :theme_digest, :string, limit: 40
    add_column :themes, :theme_dashboard_digest, :string, limit: 40
  end
end
