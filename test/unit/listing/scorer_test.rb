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

        assert_equal 0.0,   @scorer.scores[@listings.first][:boundingbox]
        assert_equal 66.67, @scorer.scores[@listings.last][:boundingbox]
      end
    end

  end

end