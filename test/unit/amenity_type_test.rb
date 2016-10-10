require 'test_helper'

class AmenityTypeTest < ActiveSupport::TestCase
  should have_many(:amenities)
  should belong_to(:instance)

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
end
