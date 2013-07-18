require 'test_helper'

class ChargeTest < ActiveSupport::TestCase

  should belong_to(:user)
  should belong_to(:reference)

end
