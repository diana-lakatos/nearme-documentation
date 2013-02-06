class CreateLocationTypes < ActiveRecord::Migration
  def up
    create_table :location_types do |t|
      t.string :name
      t.timestamps
    end
    add_column :locations, :location_type_id, :integer
    connection.execute <<-SQL
      INSERT INTO location_types (name, created_at, updated_at) VALUES
      ('Company Office', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP), 
      ('Goverment Space', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
      ('Coworking Space', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP), 
      ('Shared Office', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP), 
      ('Business Center', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
      ('Cafe', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
      ('Other', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    SQL
    connection.execute <<-SQL
      UPDATE locations
      SET
      location_type_id = 1
      WHERE
      location_type_id IS NULL
    SQL
  end

  def down
    drop_table :location_types
    remove_column :locations, :location_type_id

  end
end
