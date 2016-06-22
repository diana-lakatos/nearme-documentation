class CreatePhotoUploadVersions < ActiveRecord::Migration
  def change
    create_table :photo_upload_versions do |t|
      t.integer :theme_id, index: true
      t.integer :instance_id, index: true
      t.string :apply_transform
      t.integer :width
      t.integer :height
      t.string :photo_uploader
      t.string :version_name

      t.timestamps null: false
    end

    add_index :photo_upload_versions, [:theme_id, :version_name, :photo_uploader], unique: true, name: 'uniq_puv_theme_version_uploader'
  end
end
