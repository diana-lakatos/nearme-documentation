class CreateAmenitiesAndOrganizations < ActiveRecord::Migration
  def self.up
    create_table :amenities do |t|
      t.string :name
      t.timestamps
    end

    create_table :listing_amenities do |t|
      t.integer :listing_id
      t.integer :amenity_id
      t.timestamps
    end

    create_table :organizations do |t|
      t.string :name
      t.string :logo
      t.timestamps
    end

    create_table :listing_organizations do |t|
      t.integer :listing_id
      t.integer :organization_id
      t.timestamps
    end
  end

  def self.down
    drop_table :listing_organizations
    drop_table :organizations
    drop_table :listing_amenities
    drop_table :amenities
  end
end
