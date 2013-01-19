class CreateAddressComponentTypes < ActiveRecord::Migration
  def change
    create_table :address_component_types do |t|
      t.string :name
    end
  end
end
