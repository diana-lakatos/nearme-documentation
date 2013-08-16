require 'test_helper'

class CoordinateTest < ActiveSupport::TestCase
  context "#initialize" do
    should "work with strings" do
      coord = Coordinate.new("1", "1")
      assert_equal 1.0, coord.lat
      assert_equal 1.0, coord.long
    end
  end
end
