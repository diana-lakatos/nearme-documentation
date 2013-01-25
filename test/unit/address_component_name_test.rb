require 'test_helper'

class AddressComponentNameTest < ActiveSupport::TestCase

  should validate_presence_of(:short_name)
  should validate_presence_of(:long_name)
  should belong_to(:location)



end
