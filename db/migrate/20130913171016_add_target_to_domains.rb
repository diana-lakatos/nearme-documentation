class AddTargetToDomains < ActiveRecord::Migration
  def up
    add_column :domains, :target_id, :integer
    add_column :domains, :target_type, :string
    connection.execute <<-SQL
      UPDATE domains
      SET
        target_type = 'Instance',
        target_id = instance_id
    SQL
    # adding default domain
    # I think we really want to raise exception if Instance is not defined. Hardcoding id with "1" would work now, but I doubt that's good idea. 
    connection.execute <<-SQL
      INSERT INTO domains (name, target_id, target_type, created_at, updated_at) VALUES
        ('desksnear.me', #{Instance.default_instance.id}, 'Instance', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    SQL
    remove_column :domains, :instance_id
  end

  def down
    add_column :domains, :instance_id, :integer
    connection.execute <<-SQL
      UPDATE domains
      SET
        instance_id = target_id
      WHERE
        target_type = 'Instance'
    SQL
    connection.execute <<-SQL
      DELETE FROM domains
      WHERE
        name = 'desksnear.me'
    SQL
    remove_column :domains, :target_id
    remove_column :domains, :target_type
  end
end
