require 'test_helper'

class AmenityTest < ActiveSupport::TestCase
  should have_many(:locations).through(:amenity_holders)
  should have_many(:listings).through(:amenity_holders)
  should belong_to(:amenity_type)

  should validate_presence_of(:name)
end
