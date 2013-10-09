class AddContactPersonToLocation < ActiveRecord::Migration
  
  def up
    add_column :locations, :contact_person_id, :integer
    add_index :locations, :contact_person_id
  end

  def down
    remove_column :locations, :contact_person_id
  end
end
