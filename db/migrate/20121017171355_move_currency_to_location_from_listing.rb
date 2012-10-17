class MoveCurrencyToLocationFromListing < ActiveRecord::Migration

  def up
    add_column :locations, :currency, :string

    connection.execute <<-SQL
      UPDATE locations as l
        SET currency = li.currency
      FROM listings li
      WHERE l.id = location_id
    SQL

    remove_column :listings, :currency
  end

  def down
    add_column :listings, :currency, :string

    connection.execute <<-SQL
      UPDATE listings as l
      SET currency = lo.currency
      FROM locations lo
      WHERE l.location_id = lo.id
    SQL

    remove_column :locations, :currency
  end
end
