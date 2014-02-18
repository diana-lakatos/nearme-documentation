class AddMetadataToColumns < ActiveRecord::Migration
  def change
    add_column :companies, :metadata, :text
    add_column :locations, :metadata, :text
    add_column :listings, :metadata, :text
    add_column :users, :metadata, :text
  end
end
