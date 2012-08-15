require 'test_helper'

class AmenityTest < ActiveSupport::TestCase
  
  should have_many(:listings).through(:listing_amenities)

  should validate_presence_of(:name)

end
