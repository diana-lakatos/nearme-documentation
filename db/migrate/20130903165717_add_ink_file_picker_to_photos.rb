class AddInkFilePickerToPhotos < ActiveRecord::Migration
  class Photo < ActiveRecord::Base
  end

  def up
    add_column :photos, :image_transformation_data, :text
    add_column :photos, :image_original_url, :string
    add_column :photos, :image_versions_generated_at, :datetime, :default => nil
    Photo.update_all(image_versions_generated_at: Time.zone.now)
    remove_column :photos, :versions_generated

    add_column :users, :avatar_transformation_data, :text
    add_column :users, :avatar_original_url, :string
    add_column :users, :avatar_versions_generated_at, :datetime, :default => nil
  end

  def down
    remove_column :photos, :image_transformation_data
    remove_column :photos, :image_original_url
    add_column :photos, :versions_generated, :boolean, :default => false
    Photo.update_all(versions_generated: true)
    remove_column :photos, :image_versions_generated_at

    remove_column :users, :avatar_transformation_data
    remove_column :users, :avatar_original_url
    remove_column :users, :avatar_versions_generated_at
  end
end
