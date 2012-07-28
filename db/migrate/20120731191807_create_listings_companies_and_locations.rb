class CreateListingsCompaniesAndLocations < ActiveRecord::Migration
  def self.up
    create_table :listings do |t|
      t.references :location
      t.references :creator

      t.string :name
      t.text :description

      t.string   "currency"
      t.integer :price_cents, :default => 0
      t.integer :quantity, :default => 1

      t.float :rating_average, :default => 0.0
      t.integer :rating_count, :default => 0
      t.text :availability_rules

      t.timestamps
      t.datetime :deleted_at
    end

    create_table :companies do |t|
      t.integer :creator_id
      t.string :name
      t.string :email
      t.text :description

      t.timestamps
      t.datetime :deleted_at
    end

    create_table :locations do |t|
      t.references :company
      t.references :creator
      t.string :name
      t.string :email
      t.text :description
      t.string :address
      t.string :phone
      t.float :latitude
      t.float :longitude
      t.string :amenities
      t.text :info # Hash of geocoder data, city, region, zip, etc...

      t.timestamps
      t.datetime :deleted_at
    end
  end
  def self.down
    drop_table :listings
    drop_table :companies
    drop_table :locations
  end
end
