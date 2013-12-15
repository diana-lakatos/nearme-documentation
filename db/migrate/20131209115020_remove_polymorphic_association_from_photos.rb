class RemovePolymorphicAssociationFromPhotos < ActiveRecord::Migration
  def up
    remove_index :photos, [:content_id, :content_type]
    rename_column :photos, :content_id, :listing_id
    remove_column :photos, :content_type
    add_index :photos, :listing_id
  end

  def down
    remove_index :photos, :listing_id
    rename_column :photos, :listing_id, :content_id
    add_column :photos, :content_type, :string, :default => 'Listing'
    add_index :photos, [:content_id, :content_type]
  end

end
