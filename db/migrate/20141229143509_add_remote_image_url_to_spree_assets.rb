class AddRemoteImageUrlToSpreeAssets < ActiveRecord::Migration
  def change
    add_column :spree_assets, :remote_image_url, :string
  end
end
