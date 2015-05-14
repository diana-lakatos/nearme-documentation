class MoveFieldsFromCustAttr < ActiveRecord::Migration
  def up
    add_column :transactables, :name, :string
    add_column :transactables, :description, :text
    add_column :transactables, :confirm_reservations, :boolean
    add_column :transactables, :last_request_photos_sent_at, :datetime
    add_column :transactables, :capacity, :string

    connection.execute <<-SQL
      UPDATE transactables SET name = (properties->'name');
      UPDATE transactables SET description = (properties->'description');
      UPDATE transactables SET confirm_reservations = (properties->'confirm_reservations')::boolean;
      UPDATE transactables SET last_request_photos_sent_at = (properties->'last_request_photos_sent_at' || NULL)::timestamp;
      UPDATE transactables SET capacity = (properties->'capacity');
    SQL
  end

  def down
    remove_column :transactables, :name
    remove_column :transactables, :description
    remove_column :transactables, :confirm_reservations
    remove_column :transactables, :last_request_photos_sent_at
    remove_column :transactables, :capacity
  end
end
