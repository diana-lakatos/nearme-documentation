require 'test_helper'

class ListingTypeTest < ActiveSupport::TestCase

  should have_many(:listings)

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)

end
