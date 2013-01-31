class EmbedAddressComponentInLocation < ActiveRecord::Migration
  def up
    add_column :locations, :address_components, :text
    drop_table :address_component_names
    drop_table :address_component_types
    drop_table :address_component_names_address_component_types
  end

  def down
    remove_column :locations, :address_components
    create_table :address_component_names do |t|
      t.string :long_name
      t.string :short_name
      t.belongs_to :location
    end
    create_table :address_component_types do |t|
      t.string :name
    end
    create_table :address_component_names_address_component_types do |t|
      t.integer :address_component_name_id
      t.integer :address_component_type_id
    end
  end
end
