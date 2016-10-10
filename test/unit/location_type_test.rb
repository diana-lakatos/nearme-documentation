require 'test_helper'

class LocationTypeTest < ActiveSupport::TestCase
  should have_many(:locations)

  should validate_presence_of(:name)
end
