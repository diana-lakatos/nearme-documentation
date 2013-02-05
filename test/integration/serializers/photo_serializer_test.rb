require 'test_helper'

class PhotoSerailizerTest < ActiveSupport::TestCase
  test "#caption is an empty string when the initial objects caption is nil" do
    assert_equal "", PhotoSerializer.new(Photo.new(caption: nil)).caption
  end
end
