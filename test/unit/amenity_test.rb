require 'test_helper'

class AmenityTest < ActiveSupport::TestCase
  
  should have_many(:locations).through(:location_amenities)
  should belong_to(:amenity_type)

  should validate_presence_of(:name)

end
