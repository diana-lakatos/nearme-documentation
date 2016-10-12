require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  should belong_to(:instance)
  should belong_to(:user)
  should belong_to(:order)
end
