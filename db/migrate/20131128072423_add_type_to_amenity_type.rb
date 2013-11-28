class AddTypeToAmenityType < ActiveRecord::Migration

  class AmenityType < ActiveRecord::Base
  end

  def change
    add_column :amenity_types, :type, :string

    AmenityType.update_all(type: 'LocationAmenityType')
  end
end
