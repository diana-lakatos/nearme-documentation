class AddContactPersonToLocation < ActiveRecord::Migration
  
  def up
    add_column :locations, :administrator_id, :integer
    add_index :locations, :administrator_id
  end

  def down
    remove_column :locations, :administrator_id
  end
end
