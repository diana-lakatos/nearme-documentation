class AddMetadataToColumns < ActiveRecord::Migration
  def change
    add_column :companies, :metadata, :text, :default => '{}'
    add_column :locations, :metadata, :text, :default => '{}'
    add_column :listings, :metadata, :text, :default => '{}'
    add_column :users, :metadata, :text, :default => '{}'
  end
end
