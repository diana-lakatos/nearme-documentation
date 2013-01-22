class RemoveCreatorIdFromListingAndLocation < ActiveRecord::Migration
  def up
    remove_column :listings, :creator_id
    remove_column :locations, :creator_id
  end

  def down
    add_column :locations, :creator_id, :integer
    connection.execute <<-SQL
      UPDATE locations
      SET
        creator_id = c.creator_id
      FROM
        companies as c
      WHERE
        company_id = c.id
    SQL

    add_column :listings, :creator_id, :integer
    connection.execute <<-SQL
      UPDATE listings
      SET
        creator_id = c.creator_id
      FROM
        locations as location,
        companies as c
      WHERE
        location.id = location_id AND
        location.company_id = c.id
    SQL

  end
end
