require 'test_helper'

class Listing::ScorerTest < ActiveSupport::TestCase

  context "with a set of test listings" do

    setup do
      @listings = [ FactoryGirl.create(:listing_in_auckland), FactoryGirl.create(:listing_in_san_francisco),
                    FactoryGirl.create(:listing_in_cleveland) ]

      @scorer   = Listing::Scorer.new(@listings)
    end

    context "scoring based on distance from bounding box center" do
      should "score correctly" do
        # lat lon is for Wellington, New Zealand
        # http://goo.gl/maps/nkFQb
        @scorer.send(:score_boundingbox, lat: -41.293507, lon: 174.776279)

        assert_equal 33.33, @scorer.scores[@listings.first][:boundingbox]
        assert_equal 100.0, @scorer.scores[@listings.last][:boundingbox]
      end
    end

    context "scoring based on number of matched amenities" do
      setup do
        @wifi          = FactoryGirl.create(:amenity, name: "Wi-Fi")
        @drinks_fridge = FactoryGirl.create(:amenity, name: "Drinks Fridge")
        @pool_table    = FactoryGirl.create(:amenity, name: "Pool Table")

        @listings.first.location.amenities = [@wifi, @drinks_fridge, @pool_table]
        @listings.last.location.amenities  = [@wifi, @drinks_fridge, @pool_table]
      end

      should "score correctly" do
        @scorer.send(:score_amenities, [@wifi.id, @pool_table.id])

        # all amenities
        assert_equal 50.0, @scorer.scores[@listings.first][:amenities]
        assert_equal 50.0, @scorer.scores[@listings.last][:amenities]

        # no amenities
        assert_equal 100.0, @scorer.scores[@listings[1]][:amenities]

        # now try again with only some of the amenities (wifi is down!)
        @listings.last.location.amenities  = [@drinks_fridge, @pool_table]
        @scorer.send(:score_amenities, [@wifi.id, @pool_table.id])

        assert_equal 33.33, @scorer.scores[@listings.first][:amenities]
        assert_equal 66.67, @scorer.scores[@listings.last][:amenities]
      end
    end

    context "scoring based on number of matched organizations" do
      setup do
        @org1 = FactoryGirl.create(:organization)
        @org2 = FactoryGirl.create(:organization)

        @listings.first.location.organizations = [@org1]
      end

      should "score correctly" do
        @scorer.send(:score_organizations, [@org1.id])

        assert_equal 50.0,  @scorer.scores[@listings.first][:organizations]
        assert_equal 100.0, @scorer.scores[@listings[1]][:organizations]
        assert_equal 100.0, @scorer.scores[@listings.last][:organizations]
      end
    end

  end

end