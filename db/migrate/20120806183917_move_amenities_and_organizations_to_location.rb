class MoveAmenitiesAndOrganizationsToLocation < ActiveRecord::Migration
  def up
    add_column :listing_amenities, :location_id, :integer
    add_column :listing_organizations, :location_id, :integer

    connection.execute <<-SQL
      UPDATE listing_amenities
      SET
        location_id = l.location_id
      FROM listings AS l
      WHERE listing_id = l.id
    SQL

    connection.execute <<-SQL
      UPDATE listing_organizations
      SET
        location_id = l.location_id
      FROM listings AS l
      WHERE listing_id = l.id
    SQL

    remove_column :listing_amenities, :listing_id
    remove_column :listing_organizations, :listing_id

    rename_table :listing_amenities, :location_amenities
    rename_table :listing_organizations, :location_organizations
  end

  def down
    rename_table :location_organizations, :listing_organizations
    rename_table :location_amenities, :listing_amenities

    add_column :listing_organizations, :listing_id, :integer
    add_column :listing_amenities, :listing_id, :integer

    connection.execute <<-SQL
      UPDATE listing_amenities
      SET
        listing_id = l.id
      FROM listings AS l
      WHERE listing_amenities.location_id = l.location_id
    SQL

    connection.execute <<-SQL
      UPDATE listing_organizations
      SET
        listing_id = l.id
      FROM listings AS l
      WHERE listing_organizations.location_id = l.location_id
    SQL

    remove_column :listing_organizations, :location_id
    remove_column :listing_amenities, :location_id
  end
end
