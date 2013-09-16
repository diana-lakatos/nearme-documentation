class RenameInstanceThemesToThemes < ActiveRecord::Migration
  def up
    rename_table :instance_themes, :themes
    add_column :themes, :owner_id, :integer
    add_column :themes, :owner_type, :string
    connection.execute <<-SQL
      UPDATE themes
      SET
        owner_type = 'Instance',
        owner_id = instance_id
    SQL
    remove_column :themes, :instance_id
  end

  def down
    rename_table :themes, :instance_themes
    add_column :instance_themes, :instance_id, :integer
    connection.execute <<-SQL
      UPDATE instance_themes
      SET
        instance_id = owner_id
      WHERE
        owner_type = 'Instance'
    SQL
    remove_column :instance_themes, :owner_id
    remove_column :instance_themes, :owner_type
  end
end
