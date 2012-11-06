require 'test_helper'

class Listing::SearchTest < ActiveSupport::TestCase

  context "with some test listings" do
    setup do
      @wifi     = FactoryGirl.create(:amenity, name: "Wi-Fi")
      @listings = [ FactoryGirl.create(:listing_in_auckland), FactoryGirl.create(:listing_in_san_francisco),
        FactoryGirl.create(:listing_in_cleveland) ]

      @listings.last.location.amenities = [ @wifi ]
    end

    should "sort by score" do
      @listings.first.score = 10.0
      @listings.second.score = 30.0
      @listings.third.score = 20.0

      Listing.geocoder = stub({found_location?: false, build_geocoded_data_from_string: false })
      ThinkingSphinx::Search.any_instance.stubs(:search).with { |arg| arg.is_a?(String) }.returns(@listings)
      Listing::Scorer.stubs(:score)

      results = Listing.find_by_search_params(
        query: "Normally this would be resolved by Sphinx but here it's stubbed out",
        price: { max: 500, min: 100 },
        amenities: [ @wifi.id ]
      )

      assert_equal [10.0, 20.0, 30.0], results.map(&:score)
    end

    context "when performing a keyword search" do
      context "that can be geocoded" do

        setup do
          Listing.geocoder = stub({ found_location?: true, build_geocoded_data_from_string: true, geo_params:  { midpoint: [0,0] } })
          ThinkingSphinx::Search.any_instance.stubs(:search).with { |arg| arg.is_a?(Hash) && arg.has_key?(:geo) }.returns(@listings)
        end

        should "return matched listings with scores based on parameters" do

          results = Listing.find_by_search_params(
            query: "Normally this would be resolved by Sphinx but here it's stubbed out",
            price: { max: 500, min: 100 },
            amenities: [ @wifi.id ]
          )

          assert results.all? { |l| l.score.present? }
          assert_equal [10.0, 15.0, 15.0], results.map(&:score)
        end
      end

      context "that can not be geocoded" do
        setup do
          Listing.geocoder = stub({ found_location?: false, build_geocoded_data_from_string: nil})
          ThinkingSphinx::Search.any_instance.stubs(:search).with { |arg| arg.is_a?(String) }.returns(@listings)
        end

        should "return matched listings with scores based on parameters" do

          results = Listing.find_by_search_params(
            query: "Normally this would be resolved by Sphinx but here it's stubbed out",
            price: { max: 500, min: 100 },
            amenities: [ @wifi.id ]
          )

          assert results.all? { |l| l.score.present? }
          assert_equal [10.0, 15.0, 15.0], results.map(&:score)
        end

      end
    end

    context "when performing a geospatial search" do
      setup do
        # stub out geodistance :)
        @listings.each_with_index do |l, i|
          l.sphinx_attributes = { "@geodist" => i * 1_000 }
        end

        # stub sphinx
        ThinkingSphinx::Search.any_instance.stubs(:search).with { |arg| arg.is_a?(Hash) && arg.has_key?(:geo) }.returns(@listings)
      end

      should "return matched listings with scores based on parameters" do

        results = Listing.find_by_search_params(
          # bounding box is not actually used here as Sphinx is stubbed out
          boundingbox: {
          start: { lat: -41.293507, lon: 174.776279 },
      end:   { lat: -41.293507, lon: 174.776279 }
        },
          price: { max: 500, min: 100 },
          amenities: [ @wifi.id ]
        )

        assert results.all? { |l| l.score.present? }
        assert_equal [28.33, 41.67, 50.0], results.sort_by(&:score).map(&:score)
    end
  end

  context "when searching without either a keyword or a geospatial bounding box specified" do
    should "raise an exception" do
      assert_raises Listing::Search::SearchTypeNotSupported do
        Listing.find_by_search_params(foo: "bar")
      end
    end
  end

end

end
