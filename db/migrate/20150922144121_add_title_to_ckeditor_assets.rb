class AddTitleToCkeditorAssets < ActiveRecord::Migration
  def change
    add_column :ckeditor_assets, :title, :string
  end
end
