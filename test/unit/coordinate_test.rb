require 'test_helper'

class CoordinateTest < ActiveSupport::TestCase
  context "#initialize" do
    should "work with strings" do
      coord = Coordinate.new("1", "1")
      coord.lat.should == 1.0
      coord.long.should == 1.0
    end
  end
end
