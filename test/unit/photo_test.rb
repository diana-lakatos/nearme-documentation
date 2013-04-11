require 'test_helper'

class PhotoTest < ActiveSupport::TestCase

  should belong_to(:creator)
  should validate_presence_of(:image)
  should validate_presence_of(:content_type)
  should allow_value(nil).for(:caption)
  should ensure_length_of(:caption).is_at_most(120)
end
