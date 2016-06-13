class AddFileUpdatedAtToCustomThemeAssets < ActiveRecord::Migration
  def change
    add_column :custom_theme_assets, :file_updated_at, :datetime
  end
end
