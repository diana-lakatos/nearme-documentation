class RenameObjectToEntity < ActiveRecord::Migration
  def up
    rename_column :addresses, :object_id, :entity_id
    rename_column :addresses, :object_type, :entity_type
  end

  def down
    rename_column :addresses, :entity_id, :object_id
    rename_column :addresses, :entity_type, :object_type
  end
end
