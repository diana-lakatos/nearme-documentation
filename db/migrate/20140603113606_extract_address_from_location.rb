class ExtractAddressFromLocation < ActiveRecord::Migration

  class Address < ActiveRecord::Base
    geocoded_by :address
    serialize :address_components, JSON
    belongs_to :object, polymorphic: true
  end

  class Location < ActiveRecord::Base
    serialize :address_components, JSON
  end

  def up
    create_table :addresses do |t|
      t.integer :instance_id
      t.string :address
      t.string :address2
      t.string :formatted_address
      t.string :street
      t.string :suburb
      t.string :city
      t.string :country
      t.string :state
      t.string :postcode, limit: 10
      t.text :address_components
      t.float :latitude
      t.float :longitude
      t.integer :object_id
      t.string :object_type
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :addresses, [:object_id, :object_type]

    add_column :locations, :address_id, :integer
    add_index :locations, :address_id

    Location.find_each do |location|
      address = Address.where(object_id: location.id, object_type: 'Location').first || Address.new
      %w(address address2 formatted_address street suburb city country state postcode address_components latitude longitude).each do |field|
        address.send("#{field}=", location.send(field))
      end
      # avoid storing ExtractAddressFromLocation::Location in object_type
      address.object_id = location.id
      address.object_type = 'Location'
      address.instance_id = location.instance_id
      address.save!
      location.update_column(:address_id, address.id)
    end
  end

  def down
    drop_table :addresses
    remove_column :locations, :address_id
  end
end
