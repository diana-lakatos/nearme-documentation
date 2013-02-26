require 'test_helper'

class PhotoTest < ActiveSupport::TestCase

  should belong_to(:creator)
  should validate_presence_of(:image)
  should validate_presence_of(:content_type)
end
