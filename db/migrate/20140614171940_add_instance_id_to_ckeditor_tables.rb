class AddInstanceIdToCkeditorTables < ActiveRecord::Migration
  def change
    add_column :ckeditor_assets, :instance_id, :integer
    add_index :ckeditor_assets, :instance_id
  end
end
