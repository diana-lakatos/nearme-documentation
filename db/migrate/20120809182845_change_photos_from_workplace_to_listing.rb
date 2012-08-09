class ChangePhotosFromWorkplaceToListing < ActiveRecord::Migration
  def up
    connection.execute <<-SQL
      UPDATE photos
      SET
        content_type = 'Listing'
      WHERE
        content_type ='Workplace'
    SQL
  end

  def down
    connection.execute <<-SQL
      UPDATE photos
      SET
        content_type = 'Workplace'
      WHERE
        content_type ='Listing'
    SQL
  end
end
