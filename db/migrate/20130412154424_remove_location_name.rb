class RemoveLocationName < ActiveRecord::Migration
  def up
   ActiveRecord::Base.connection.execute("
      UPDATE companies AS c
      SET name = l.name
      FROM locations AS l
      WHERE c.id = l.company_id
        AND (
          c.name IS NULL 
          OR c.name LIKE ''
        )
    ")
    remove_column :locations, :name
  end

  def down
    add_column :locations, :name, :string
   ActiveRecord::Base.connection.execute("
      UPDATE locations AS l
      SET name = concat_ws(' @ ', c.name, l.street)
      FROM companies AS c
      WHERE c.id = l.company_id
    ")
  end
end
