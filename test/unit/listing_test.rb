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
    listing_with_amenity = FactoryGirl.create(:listing_with_amenity)
    listing_without_amenity = FactoryGirl.create(:listing)

    search_params = search_all_over_the_world()
    search_params['amenities'] = [listing_with_amenity.amenities.first.id]
    listings = Listing.find_by_search_params(search_params)

    assert listings.include?(listing_with_amenity), "Listings includes listing with amenity"
    assert !listings.include?(listing_without_amenity), "Listings dont include listing without amenity"
  end

  test "find_by_search_params restricts based upon organizations" do
    search_params = search_all_over_the_world
    listing_with_organization = FactoryGirl.create(:listing_with_organization)
    search_params['organizations'] = [listing_with_organization.organizations.first.id]
    listing_without_organization = FactoryGirl.create(:listing)
    listings = Listing.find_by_search_params(search_params)
    assert listings.include?(listing_with_organization), "Listings includes listing with organization"
    assert !listings.include?(listing_without_organization), "Listings dont include listing without organization"
  end

  should belong_to(:location)
  should belong_to(:creator)
  should have_many(:reservations)
  should have_many(:ratings)

  should validate_presence_of(:location_id)
  should validate_presence_of(:creator_id)
  should validate_presence_of(:name)
  should validate_presence_of(:description)
  should validate_presence_of(:quantity)
  should ensure_inclusion_of(:confirm_reservations).in_array([true,false])
  should validate_numericality_of(:price_cents)
  should validate_numericality_of(:quantity)

  def search_all_over_the_world
    {
      "boundingbox" => {
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
