class CreateListingUnitPrices < ActiveRecord::Migration
  def up
    create_table :listing_unit_prices do |t|
      t.integer :listing_id
      t.integer :price_cents
      t.integer :period
      t.timestamps
    end
    connection.execute <<-SQL
      INSERT INTO listing_unit_prices
        (listing_id, price_cents, period, created_at, updated_at)
      SELECT l.id, l.price_cents, 1440, NOW(), NOW()
      FROM listings l
    SQL

    remove_column :listings, :price_cents
  end

  def down
    add_column :listings, :price_cents, :integer

    connection.execute <<-SQL
      UPDATE listings as l
      SET price_cents = lup.price_cents
      FROM listing_unit_prices lup
      WHERE l.id = listing_id AND period = 1440
    SQL

    drop_table :listing_unit_prices
  end
end
