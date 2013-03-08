class AddUserToPhotos < ActiveRecord::Migration
  def up
    add_column :photos, :creator_id, :integer
    connection.execute <<-SQL
      UPDATE photos
        SET creator_id = c.creator_id
        FROM
          companies as c
        INNER JOIN
          locations as lo ON c.id = lo.company_id
        INNER JOIN
          listings as li ON lo.id = li.location_id
        WHERE
          photos.content_type = 'Listing' and photos.content_id = li.id;
    SQL
  end

  def down
    remove_column :photos, :creator_id
  end
end
