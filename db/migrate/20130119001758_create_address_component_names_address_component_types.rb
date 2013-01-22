class CreateAddressComponentNamesAddressComponentTypes < ActiveRecord::Migration
  def up
    create_table :address_component_names_address_component_types do |t|
      t.integer :address_component_name_id
      t.integer :address_component_type_id
    end
  end

  def down
    drop_table :address_component_names_address_component_types
  end
end
