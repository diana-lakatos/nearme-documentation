class CreateInstances < ActiveRecord::Migration
  def up
    create_table :instances do |t|
      t.string :name
      t.timestamps
    end
    connection.execute <<-SQL
      INSERT INTO instances (name, created_at, updated_at) VALUES
        ('DesksNearMe', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    SQL
    add_column :companies, :instance_id, :integer
    add_index :companies, :instance_id
    add_column :users, :instance_id, :integer
    add_index :users, :instance_id
    connection.execute <<-SQL
      update companies set instance_id = 1;
      update users set instance_id = 1;
    SQL
    connection.execute <<-SQL
      INSERT INTO amenities (name, amenity_type_id, created_at, updated_at) VALUES
        ('Catering', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    SQL
  end

  def down
    drop_table :instances
    remove_column :companies, :instance_id
    remove_column :users, :instance_id
    connection.execute <<-SQL
      DELETE from amenities where name LIKE 'Catering'
    SQL
  end
end
