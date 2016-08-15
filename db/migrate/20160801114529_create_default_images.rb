class CreateDefaultImages < ActiveRecord::Migration
  def change
    create_table :default_images do |t|
      t.integer :theme_id, index: true
      t.integer :instance_id, index: true
      t.string :photo_uploader
      t.string :photo_uploader_version

      t.string :photo_uploader_image
      t.text :photo_uploader_image_transformation_data
      t.string :photo_uploader_image_original_url
      t.datetime :photo_uploader_image_versions_generated_at
      t.integer :photo_uploader_image_original_width
      t.integer :photo_uploader_image_original_height

      t.timestamps
    end
  end
end
