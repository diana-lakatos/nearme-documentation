require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  
  should have_many(:listings).through(:listing_organizations)

  should validate_presence_of(:name)

end