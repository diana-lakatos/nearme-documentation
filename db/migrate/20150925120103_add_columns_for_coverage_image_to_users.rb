class AddColumnsForCoverageImageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cover_image_original_height, :integer
    add_column :users, :cover_image_original_width, :integer
    add_column :users, :cover_image_transformation_data, :text
    add_column :users, :cover_image_original_url, :string
    add_column :users, :cover_image_versions_generated_at, :datetime, default: nil
  end
end
