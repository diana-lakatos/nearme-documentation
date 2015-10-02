class AddPhotosToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :about, :text

    add_column :topics, :cover_image, :string
    add_column :topics, :cover_image_original_height, :integer
    add_column :topics, :cover_image_original_width, :integer
    add_column :topics, :cover_image_transformation_data, :text
    add_column :topics, :cover_image_original_url, :string
    add_column :topics, :cover_image_versions_generated_at, :datetime, default: nil

    add_column :topics, :image, :string
    add_column :topics, :image_original_height, :integer
    add_column :topics, :image_original_width, :integer
    add_column :topics, :image_transformation_data, :text
    add_column :topics, :image_original_url, :string
    add_column :topics, :image_versions_generated_at, :datetime, default: nil
  end
end
