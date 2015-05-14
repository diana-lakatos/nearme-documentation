class FixAssociationsWithTt < ActiveRecord::Migration
  def up
    connection.execute <<-SQL
      UPDATE form_components SET form_componentable_type = 'ServiceType' WHERE form_componentable_type = 'TransactableType';
      UPDATE data_uploads SET importable_type = 'ServiceType' WHERE importable_type = 'TransactableType';
      UPDATE categories SET categorable_type = 'ServiceType' WHERE categorable_type = 'TransactableType';
      UPDATE schedules SET scheduable_type = 'ServiceType' WHERE scheduable_type = 'TransactableType';
      UPDATE custom_attributes SET target_type = 'ServiceType' WHERE target_type = 'TransactableType';
    SQL
  end
end
