require 'test_helper'

class Listing::SearchTest < ActiveSupport::TestCase
  setup do
    @wifi     = FactoryGirl.create(:amenity, name: "Wi-Fi")
    @listing_in_auckland = FactoryGirl.create(:listing_in_auckland)
    @listing_in_san_fran = FactoryGirl.create(:listing_in_san_francisco)
    @listing_in_cleveland = FactoryGirl.create(:listing_in_cleveland)
    @listings = [ @listing_in_auckland, @listing_in_san_fran, @listing_in_cleveland ]

    @listings.last.location.amenities = [ @wifi ]
    @search_area_in_san_fran = Listing::Search::Area.new(Coordinate.new(-36.858675, 174.777303), 500.0)
    Listing.stubs(:search).returns(@listings)
  end


  describe ".find_by_search_params" do
    context "when not a keyword search" do
      should "search for only the scope" do
        params = stub(keyword_search?: false, query: 'Address', to_scope: { a: 'b' })
        Listing.expects(:search).with({ a: 'b' }).returns(@listings)
        Listing.find_by_search_params(params)
      end
    end
    context "when a keyword search" do
      should "searches for the scope with the query" do
        params = stub(keyword_search?: true, query: 'hooray', to_scope: { a: 'b' })
        Listing.expects(:search).with('hooray', { a: 'b' }).returns(@listings)
        Listing.find_by_search_params(params)
      end
    end
  end
end
