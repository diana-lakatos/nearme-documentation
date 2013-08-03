class AddMetaTitleToInstance < ActiveRecord::Migration
  def up
    add_column :instances, :meta_title, :string

    connection.execute <<-SQL
      UPDATE instances
      SET meta_title=site_name;
    SQL
  end

  def down
    remove_column :instances, :meta_title
  end
end
