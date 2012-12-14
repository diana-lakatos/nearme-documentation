require 'test_helper'

class MidpointTest < ActiveSupport::TestCase
  context "#center" do
    should "work with strings" do
      midpoint = Midpoint.new("1", "1", "2", "2").center
      midpoint.lat.should == 1.5000570914791973
      midpoint.long.should == 1.4998857365616758
    end
  end
end
