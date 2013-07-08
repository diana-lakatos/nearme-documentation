require 'test_helper'

class InstanceTest < ActiveSupport::TestCase
  should belong_to(:partner)
end
