class MarkSomeCustomAttributesAsInternal < ActiveRecord::Migration
  def up
    connection.execute <<-SQL
      UPDATE custom_attributes
      SET internal = 't'
      WHERE
        (
        custom_attributes.name like 'name' OR
        custom_attributes.name like 'description' OR
        custom_attributes.name like 'quantity' OR
        custom_attributes.name like 'confirm_reservations' OR
        custom_attributes.name like 'last_request_photos_sent_at'
        ) AND
        custom_attributes.target_type like 'TransactableType'
    SQL
  end

  def down
    connection.execute <<-SQL
      UPDATE custom_attributes
      SET internal = 'f'
      WHERE
        (
        custom_attributes.name like 'name' OR
        custom_attributes.name like 'description' OR
        custom_attributes.name like 'quantity' OR
        custom_attributes.name like 'confirm_reservations' OR
        custom_attributes.name like 'last_request_photos_sent_at'
        ) AND
        custom_attributes.target_type like 'TransactableType'
    SQL
  end
end
