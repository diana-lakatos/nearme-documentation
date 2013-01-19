class CreateAddressComponentNames < ActiveRecord::Migration
  def change
    create_table :address_component_names do |t|
      t.string :long_name
      t.string :short_name
      t.belongs_to :location
    end
  end
end
