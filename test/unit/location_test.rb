require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test "it exists" do
    assert Location
  end

  test "it has a company" do
    @location = Location.new
    @location.company = Company.new

    assert @location.company
  end

  test "it has a creator" do
    @location = Location.new
    @location.creator = User.new

    assert @location.creator
  end

  test "it has listings" do
    @location = Location.new
    @location.listings << Listing.new
    @location.listings << Listing.new
    @location.listings << Listing.new

    assert @location.listings
  end
end
