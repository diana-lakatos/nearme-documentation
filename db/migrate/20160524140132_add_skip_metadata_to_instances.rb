class AddSkipMetadataToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :skip_meta_tags, :boolean, default: false
  end
end
