class CreateListingTypes < ActiveRecord::Migration
  def up
    create_table :listing_types do |t|
      t.string :name
      t.timestamps
    end
    add_column :listings, :listing_type_id, :integer
    connection.execute <<-SQL
      INSERT INTO listing_types (name, created_at, updated_at) VALUES
        ('Desk', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP), 
        ('Event Space', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
        ('Meeting Room', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP), 
        ('Office Space', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP), 
        ('Room', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    SQL
    connection.execute <<-SQL
      UPDATE listings
      SET
        listing_type_id = 1
      WHERE
        listing_type_id IS NULL
    SQL
  end

  def down
    drop_table :listing_types
    remove_column :listings, :listing_type_id
  end
end
