class AddUploaderIdToSpreeImages < ActiveRecord::Migration
  def change
    add_column :spree_assets, :uploader_id, :integer, index: true
    add_column :spree_assets, :instance_id, :integer, index: true
  end
end
