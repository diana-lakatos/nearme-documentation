class ConvertWorkplacesToListingsAndLocations < ActiveRecord::Migration
  def up
    add_column :companies, :url, :string
    add_column :listings, :confirm_bookings, :boolean
    add_column :locations, :formatted_address, :string
    add_column :feeds, :listing_id, :integer
    add_index :feeds, :listing_id, :name => :index_feeds_on_listing_id
    remove_index :feeds, :workplace_id

    add_column :companies, :workplace_id, :integer

    connection.execute <<-SQL
      INSERT INTO companies
        (id, workplace_id, creator_id, name, description, url, created_at, updated_at)
      SELECT id, id, creator_id, name, company_description, url, created_at, updated_at
      FROM workplaces
      WHERE fake = false
    SQL

    connection.execute <<-SQL
      SELECT setval('companies_id_seq', (SELECT max(id) + 1 FROM companies));
    SQL

    add_column :locations, :workplace_id, :integer

    connection.execute <<-SQL
      INSERT INTO locations
        (id, workplace_id, creator_id, name, description, address, latitude, longitude, created_at, updated_at,
         formatted_address)
      SELECT id, id, creator_id, name, description, address, latitude, longitude, created_at, updated_at,
        formatted_address
      FROM workplaces
      WHERE fake = false
    SQL

    connection.execute <<-SQL
      SELECT setval('locations_id_seq', (SELECT max(id) + 1 FROM locations));
    SQL

    connection.execute <<-SQL
      UPDATE locations
      SET company_id = c.id
      FROM companies c
      WHERE c.workplace_id = locations.workplace_id
    SQL

    add_column :listings, :workplace_id, :integer

    connection.execute <<-SQL
      INSERT INTO listings
        (id, workplace_id, creator_id, name, description, quantity, created_at, updated_at)
      SELECT id, id, creator_id, name, description, maximum_desks, created_at, updated_at
      FROM workplaces
      WHERE fake = false
    SQL

    connection.execute <<-SQL
      SELECT setval('listings_id_seq', (SELECT max(id) + 1 FROM listings));
    SQL

    connection.execute <<-SQL
      UPDATE listings
      SET location_id = l.id
      FROM locations l
      WHERE l.workplace_id = listings.workplace_id
    SQL

    connection.execute <<-SQL
      UPDATE feeds
      SET listing_id = listings.workplace_id
      FROM listings
      WHERE listings.workplace_id = feeds.workplace_id
    SQL

    add_column :bookings, :listing_id, :integer

    connection.execute <<-SQL
      UPDATE bookings
      SET listing_id = listings.id
      FROM listings
      WHERE bookings.workplace_id = listings.workplace_id
    SQL

    remove_column :bookings, :workplace_id
    remove_column :feeds, :workplace_id
    remove_column :listings, :workplace_id
    remove_column :locations, :workplace_id
    remove_column :companies, :workplace_id

    drop_table :workplaces
  end

  def down
    create_table :workplaces do |t|
      t.string   "name"
      t.integer  "maximum_desks"
      t.text     "description"
      t.text     "company_description"
      t.text     "address"
      t.boolean  "confirm_bookings"
      t.integer  "creator_id"
      t.float    "latitude"
      t.float    "longitude"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "description_html"
      t.text     "company_description_html"
      t.text     "url"
      t.string   "formatted_address"
      t.boolean  "fake",                     :default => false, :null => false
      t.integer  "bookings_count",           :default => 0,     :null => false
      t.integer  "listing_id"
    end

    connection.execute <<-SQL
      INSERT INTO workplaces
        (id, listing_id, name, maximum_desks, description, company_description, address,
         confirm_bookings, latitude, longitude, url, created_at, updated_at, formatted_address)
      SELECT listings.id, listings.id, listings.name, listings.quantity, listings.description, companies.description,
        locations.address, listings.confirm_bookings, locations.latitude,
        locations.longitude, companies.url, listings.created_at, listings.updated_at,
        locations.formatted_address
      FROM listings
      INNER JOIN locations ON locations.id = listings.location_id
      INNER JOIN companies ON locations.company_id = companies.id
    SQL

    connection.execute <<-SQL
      SELECT setval('workplaces_id_seq', (SELECT max(id) + 1 FROM workplaces));
    SQL

    add_column :feeds, :workplace_id, :integer
    add_index :feeds, :workplace_id, :name => :index_feeds_on_workplace_id

    connection.execute <<-SQL
      UPDATE feeds
      SET workplace_id = workplaces.id
      FROM workplaces
      WHERE workplaces.listing_id = feeds.listing_id
    SQL

    remove_index :feeds, :name => :index_feeds_on_listing_id
    remove_column :feeds, :listing_id

    add_column :bookings, :workplace_id, :integer

    connection.execute <<-SQL
      UPDATE bookings
      SET workplace_id = workplaces.id
      FROM workplaces
      WHERE workplaces.listing_id = bookings.listing_id
    SQL

    remove_column :bookings, :listing_id

    remove_column :listings, :confirm_bookings
    remove_column :locations, :formatted_address
    remove_column :companies, :url
  end
end
