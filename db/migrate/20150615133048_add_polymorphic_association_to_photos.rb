class AddPolymorphicAssociationToPhotos < ActiveRecord::Migration
  def up
    add_column :photos, :owner_id, :integer
    add_column :photos, :owner_type, :string
    connection.execute <<-SQL
      UPDATE photos
      SET
        owner_type = 'Transactable',
        owner_id = transactable_id
      WHERE
        owner_id IS NULL AND transactable_id IS NOT NULL
    SQL
    add_index :photos, [:instance_id, :owner_id, :owner_type], name: 'index_photos_on_owner'
  end


  def down
    remove_column :photos, :owner_id
    remove_column :photos, :owner_type
  end
end
