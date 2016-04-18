class FixAssociationsWithTt < ActiveRecord::Migration
  def up
    connection.execute <<-SQL
      UPDATE form_components SET form_componentable_type = 'TransactableType' WHERE form_componentable_type = 'TransactableType';
      UPDATE data_uploads SET importable_type = 'TransactableType' WHERE importable_type = 'TransactableType';
      UPDATE categories SET categorable_type = 'TransactableType' WHERE categorable_type = 'TransactableType';
      UPDATE schedules SET scheduable_type = 'TransactableType' WHERE scheduable_type = 'TransactableType';
      UPDATE custom_attributes SET target_type = 'TransactableType' WHERE target_type = 'TransactableType';
    SQL
  end
end
