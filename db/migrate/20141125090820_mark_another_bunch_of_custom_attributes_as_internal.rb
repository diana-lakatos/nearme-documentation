class MarkAnotherBunchOfCustomAttributesAsInternal < ActiveRecord::Migration
  def up
    connection.execute <<-SQL
      UPDATE custom_attributes
      SET internal = 't'
      WHERE
        (
        custom_attributes.name like 'capacity' OR
        custom_attributes.name like 'minimum_booking_minutes' OR
        custom_attributes.name like 'listing_type'
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
        custom_attributes.name like 'capacity' OR
        custom_attributes.name like 'minimum_booking_minutes' OR
        custom_attributes.name like 'listing_type'
        ) AND
        custom_attributes.target_type like 'TransactableType'
    SQL
  end
end
