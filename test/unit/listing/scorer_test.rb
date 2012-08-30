require 'test_helper'

class Listing::ScorerTest < ActiveSupport::TestCase

  context "with a set of test listings" do

    setup do
      @listings = [ FactoryGirl.create(:listing_in_auckland), FactoryGirl.create(:listing_in_san_francisco),
                    FactoryGirl.create(:listing_in_cleveland) ]

      @scorer   = Listing::Scorer.new(@listings)
    end

    context "with some listings that have amenities, prices and organisations" do
      setup do
        @wifi          = FactoryGirl.create(:amenity, name: "Wi-Fi")
        @drinks_fridge = FactoryGirl.create(:amenity, name: "Drinks Fridge")

        @org           = FactoryGirl.create(:organization)

        @listings.first.price_cents = 234.50 * 100
        @listings[1].price_cents    = 900.00 * 100
        @listings.last.price_cents  = 123.90 * 100

        @search_params = {
          boundingbox:   { lat: -41.293507, lon: 174.776279 },
          amenities:     [ @wifi.id, @drinks_fridge.id ],
          organizations: [ @org.id ],
          price:         { min: 100, max: 900 }
        }
      end

      context "overall scoring" do
        should "correctly score and weight all components " do

          Listing::Scorer.score(@listings, @search_params)

          assert_equal 28.33, @listings.first.score
          assert_equal 60.0,  @listings.last.score
          assert_equal 51.67, @listings[1].score
        end
      end

      context "with strict matches" do
        should "return strict_match as true for listings which fall exactly within the criteria" do
          @listings.first.location.amenities     = [ @wifi, @drinks_fridge ]
          @listings.first.location.organizations = [ @org ]

          Listing::Scorer.score(@listings, @search_params.merge(price: { min: 100, max: 250 }))

          assert_equal [true, false, false], @listings.map(&:strict_match)
        end
      end
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
        assert_equal 33.33, @scorer.scores[@listings.first][:amenities]
        assert_equal 33.33, @scorer.scores[@listings.last][:amenities]

        # no amenities
        assert_equal 66.67, @scorer.scores[@listings[1]][:amenities]

        # now try again with only some of the amenities (wifi is down!)
        @listings.last.location.amenities  = [@drinks_fridge, @pool_table]
        @scorer.send(:score_amenities, [@wifi.id, @pool_table.id])

        assert_equal 33.33, @scorer.scores[@listings.first][:amenities]
        assert_equal 66.67, @scorer.scores[@listings.last][:amenities]
      end

      should "score correctly if amenity ids are specified as strings" do
        @scorer.send(:score_amenities, [@wifi.id.to_s, @pool_table.id.to_s])

        assert_equal 33.33, @scorer.scores[@listings.first][:amenities]
        assert_equal 33.33, @scorer.scores[@listings.last][:amenities]
        assert_equal 66.67, @scorer.scores[@listings[1]][:amenities]
      end

      should "return a strict_match if all requested amenities are available" do
        @scorer.send(:score_amenities, [@wifi.id, @drinks_fridge.id])

        assert @scorer.strict_matches[@listings.first][:amenities]
        assert !@scorer.strict_matches[@listings[1]][:amenities]
        assert @scorer.strict_matches[@listings.last][:amenities]
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

        assert_equal 33.33, @scorer.scores[@listings.first][:organizations]
        assert_equal 66.67, @scorer.scores[@listings[1]][:organizations]
        assert_equal 66.67, @scorer.scores[@listings.last][:organizations]
      end

      should "score correctly if organization ids are specified as strings" do
        @scorer.send(:score_organizations, [@org1.id.to_s])

        assert_equal 33.33, @scorer.scores[@listings.first][:organizations]
        assert_equal 66.67, @scorer.scores[@listings[1]][:organizations]
        assert_equal 66.67, @scorer.scores[@listings.last][:organizations]
      end

      should "return a strict_match if the listing is a member of all requested organizations" do
        @scorer.send(:score_organizations, [@org1.id])

        assert @scorer.strict_matches[@listings.first][:organizations]
        assert !@scorer.strict_matches[@listings[1]][:organizations]
        assert !@scorer.strict_matches[@listings.last][:organizations]
      end
    end

    context "scoring based on price" do
      setup do
        @listings.first.price_cents = 234.50 * 100
        @listings[1].price_cents    = 900.00 * 100
        @listings.last.price_cents  = 123.90 * 100
      end

      should "score correctly" do
        @scorer.send(:score_price, min: 150, max: 300)

        assert_equal 33.33, @scorer.scores[@listings.first][:price]
        assert_equal 66.67, @scorer.scores[@listings.last][:price]
        assert_equal 100.0, @scorer.scores[@listings[1]][:price]
      end

      should "score correctly when prices are specified as strings" do
        @scorer.send(:score_price, min: "150", max: "300")

        assert_equal 33.33, @scorer.scores[@listings.first][:price]
        assert_equal 66.67, @scorer.scores[@listings.last][:price]
        assert_equal 100.0, @scorer.scores[@listings[1]][:price]
      end

      # i.e $50 more expensive than requested is the same as $50 cheaper
      should "score listings based on absolute difference from the price range" do
        @listings.first.price_cents = 150 * 100
        @listings.last.price_cents  = 50 * 100

        @scorer.send(:score_price, min: 100, max: 100)

        assert_equal 33.33, @scorer.scores[@listings.first][:price]
        assert_equal 33.33, @scorer.scores[@listings.last][:price]
      end

      should "return a strict match if the listing price is between the minimum and maximum range" do
        @scorer.send(:score_price, min: 150, max: 250)

        assert @scorer.strict_matches[@listings.first][:price]
        assert !@scorer.strict_matches[@listings[1]][:price]
        assert !@scorer.strict_matches[@listings.last][:price]
      end

    end

    context "scoring based on availability" do
      setup do
        @start_date = 5.days.ago.to_date
        @end_date   = Time.now.to_date

        @listings.each { |l| l.update_attribute(:quantity, 2) }

        create_reservation_for(@start_date, @end_date, @listings.first)

        assert_equal 1, @listings.first.availability_for(@start_date)
        assert_equal 2, @listings.last.availability_for(@start_date)
      end

      should "score correctly" do
        @scorer.send(:score_availability, date: { start: @start_date, end: @end_date }, quantity: { min: 1 })

        assert_equal 33.33, @scorer.scores[@listings.first][:availability]
        assert_equal 33.33, @scorer.scores[@listings.last][:availability]
      end

      should "score correctly if minimum quantity is specified as a string" do
        @scorer.send(:score_availability, date: { start: @start_date, end: @end_date }, quantity: { min: "1" })

        assert_equal 33.33, @scorer.scores[@listings.first][:availability]
        assert_equal 33.33, @scorer.scores[@listings.last][:availability]
      end

      should "return a strict match if enough desks are available for each day in the range" do
        2.times { create_reservation_for(@start_date, @end_date, @listings[1]) }
        assert_equal 0, @listings[1].availability_for(@start_date)

        @scorer.send(:score_availability, date: { start: @start_date, end: @end_date }, quantity: { min: 2 })

        assert !@scorer.strict_matches[@listings.first][:availability] # only 1 desk available
        assert !@scorer.strict_matches[@listings[1]][:availability]    # no desks available
        assert @scorer.strict_matches[@listings.last][:availability]   # 2 desks available
      end
    end

  end

  private

    def create_reservation_for(start_date, end_date, listing)
      periods = (start_date...end_date).map do |d|
        ReservationPeriod.new(date: d, listing_id: listing.id)
      end

      r = listing.reservations.new(periods: periods)
      r.user = FactoryGirl.create(:user)
      r.save!
    end

end