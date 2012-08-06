require 'test_helper'

class ListingTest < ActiveSupport::TestCase
  test "find_by_search_params restricts based upon bounding" do
    search_params = {
      "boundingbox" => {
        "start" => {
          "lat" => 0.0,
          "lon" => 0.0
        },
        "end" => {
          "lat" => 10.0,
          "lon" => 10.0
        }
      }
    }
    out_of_scope_listing = FactoryGirl.create(:listing)
    in_scope_listing = FactoryGirl.create(:listing_at_5_5)
    listings = Listing.find_by_search_params(search_params)
    assert !listings.include?(out_of_scope_listing), "Listings do not include out of scope listing"
    assert listings.include?(in_scope_listing), "Listings include in scope listing"
  end

  test "find_by_search_params restricts based upon amenities" do
    search_params = search_all_over_the_world()
    search_params['amenities'] = [1]
    listing_with_amenity = FactoryGirl.create(:listing_with_amenity)
    listing_without_amenity = FactoryGirl.create(:listing)
    listings = Listing.find_by_search_params(search_params)
    assert listings.include?(listing_with_amenity), "Listings includes listing with amenity"
    assert !listings.include?(listing_without_amenity), "Listings dont include listing without amenity"
  end

  test "find_by_search_params restricts based upon organizations" do
    search_params = search_all_over_the_world()
    listing_with_organization = FactoryGirl.create(:listing_with_organization)
    search_params['organizations'] = [listing_with_organization.organizations.first.id]
    listing_without_organization = FactoryGirl.create(:listing)
    listings = Listing.find_by_search_params(search_params)
    assert listings.include?(listing_with_organization), "Listings includes listing with organization"
    assert !listings.include?(listing_without_organization), "Listings dont include listing without organization"
  end

  test "it exists" do
    assert Listing
  end

  test "it has a location" do
    @listing = Listing.new
    @listing.location = Location.new

    assert @listing.location
  end

  test "it has a creator" do
    @listing = Listing.new
    @listing.creator = User.new

    assert @listing.creator
  end

  test "it has reservations" do
    @listing = Listing.new
    3.times { @listing.reservations << Reservation.new }

    assert @listing.reservations
  end

  test "it has ratings" do
    @listing = Listing.new
    3.times { @listing.ratings << Rating.new }

    assert @listing.ratings
  end

  def search_all_over_the_world
    return {
      "bounding_box" => {
        "start" => {
          "lat" => -180.0,
          "lon" => -180.0
        },
        "end" => {
          "lat" => 180.0,
          "lon" => 180.0
        }
      }
    }
  end
end
