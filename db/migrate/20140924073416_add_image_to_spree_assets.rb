class AddImageToSpreeAssets < ActiveRecord::Migration
  def change
    add_column :spree_assets, :image, :string
    add_column :spree_assets, :image_original_url, :string
    add_column :spree_assets, :image_versions_generated_at, :datetime
    add_column :spree_assets, :image_transformation_data, :text
    add_column :spree_assets, :image_original_height, :integer
    add_column :spree_assets, :image_original_width, :integer
  end
end
