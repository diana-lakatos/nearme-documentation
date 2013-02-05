require 'test_helper'
class Listing::Search::Params
class AvailabilityTest <  ActiveSupport::TestCase
  context "#dates after initialized with a date hash of empty strings" do
    should "be an empty array" do
      availability = Availability.new({:dates=>{:start=>"", :end=>""}})
      assert_equal [], availability.dates
    end
  end

  context "#dates after initialized without a dates entry" do
    should "be an empty array" do
      availability = Availability.new({"Some thing" => "that has no meaning" })
      assert_equal [], availability.dates
    end
  end
end
end
