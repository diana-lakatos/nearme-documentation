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
    remove_column :domains, :target_id
    remove_column :domains, :target_type
  end
end
