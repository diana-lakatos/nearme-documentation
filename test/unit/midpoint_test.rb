require 'test_helper'

class MidpointTest < ActiveSupport::TestCase
  context "#center" do
    should "work with strings" do
      midpoint = Midpoint.new("1", "1", "2", "2").center
      assert_equal 1.5000570914791973, midpoint.lat
      assert_equal 1.4998857365616758, midpoint.long
    end
  end
end
