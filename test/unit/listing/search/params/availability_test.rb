require 'test_helper'

class Listing::Search::Params::AvailabilityTest <  ActiveSupport::TestCase
  context "#dates after initialized with a date hash of empty strings" do
    should "be an empty array" do
      availability = Listing::Search::Params::Availability.new({:dates=>{:start=>"", :end=>""}})
      assert_equal [], availability.dates
    end
  end

  context "#dates after initialized without a dates entry" do
    should "be an empty array" do
      availability = Listing::Search::Params::Availability.new({"Some thing" => "that has no meaning" })
      assert_equal [], availability.dates
    end
  end
end
