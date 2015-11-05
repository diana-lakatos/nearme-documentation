class AddAccessLevelToCkeditorAssets < ActiveRecord::Migration
  def change
    add_column :ckeditor_assets, :access_level, :string, limit: 255
  end
end
