class UpdatePhotosToApiPhotos < ActiveRecord::Migration
  def up
    change_table :photos do |t|
      t.integer  :content_id

      t.string   :image
      t.string   :caption
      t.string   :content_type
      t.integer  :position
      t.datetime :deleted_at
    end

    connection.execute <<-SQL
      UPDATE photos
      SET
        content_id = workplace_id,
        image = file,
        caption = description,
        content_type = 'Workplace'
    SQL

    remove_column :photos, :workplace_id
    remove_column :photos, :file
    remove_column :photos, :description
  end

  def down
    add_column :photos, :description, :string
    add_column :photos, :file, :string
    add_column :photos, :workplace_id, :integer

    connection.execute <<-SQL
      UPDATE photos
      SET
        workplace_id = content_id,
        file = image,
        description = caption
    SQL

    remove_column :photos, :content_id
    remove_column :photos, :image
    remove_column :photos, :caption
    remove_column :photos, :content_type
    remove_column :photos, :position
    remove_column :photos, :deleted_at
  end
end
