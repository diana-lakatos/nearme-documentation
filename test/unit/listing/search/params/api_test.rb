require 'test_helper'

class Listing::Search::Params::ApiTest <  ActiveSupport::TestCase
  setup do
    @params = let(:params)
    @geocoder = let(:geocoder)
  end

  describe "#new" do
    let(:params) { Listing::Search::Params::Api.new(options, geocoder) }
    let(:geocoder) { stub("Geocoder", find_location: false) }

    describe "when created with neither query, nor bounding box" do
      should "Raise SearchTypeNotSupported" do
        proc do
          Listing::Search::Params::Api.new({}, geocoder)
        end.should_raise Listing::Search::SearchTypeNotSupported
      end
    end
  end

  describe("#query") do
    let(:params) { Listing::Search::Params::Api.new(options, geocoder) }
    let(:geocoder) { stub("Geocoder", find_location: false) }

    describe "when created with a query that is not found" do
      let(:options) { { query: "not_found_location" } }
      should "keep the query" do params.query.should_equal "not_found_location" end
    end

    describe "When created with a query that was found" do
      let(:options) { { query: "found_location" } }
      let(:geocoder) { stub({ find_location: true }) }
      should "remove the query" do params.query.should_equal nil end
    end
  end

  describe "#to_scope" do
    let(:params) { Listing::Search::Params::Api.new(options, geocoder) }
    let(:geocoder) { stub("Geocoder", find_location: false) }

    let(:scope) { params.to_scope }
    let(:options) { { query: "asdf" } }
    should "never include deleted items" do
      scope[:with][:deleted_at].should_equal 0
    end

    should "always includes an organization id of 0" do
      scope[:with][:organization_ids].should_equal [0]
    end

    describe "when a user is provided" do
      let(:options) { { query: "asdf", user: Struct.new(:organization_ids).new([1,2,3]) } }
      should "includes the organization ids in the with section" do
        scope[:with][:organization_ids].should_equal [1,2,3,0]
      end
    end

    describe "when a query is found" do
      let(:geocoder) { stub({find_location: search_area}) }
      let(:search_area) { Listing::Search::Area.new(midpoint, 5.0) }
      let(:midpoint) { Coordinate.new(1,1) }

      should "gives the locations radians to the geo section"  do
        scope[:geo].should_equal midpoint.radians
      end
      should "gives the radius to the with section" do
        scope[:with]["@geodist"].should_equal 0.0...5.0
      end
    end

    describe "when a query is not found" do

      should "does not include the @geodist in with" do
        scope[:with].has_key?("@geodist").should_equal false
      end
      should "does not set the geo value" do
        scope.has_key?(:geo).should_equal false
      end
    end

    describe "when a center is provided" do
      let(:options) { { location: { lat: 37.0, lon: 128.0 } } }
      should "gives the midpoints radians to the geo section" do
        scope[:geo].should_equal Coordinate.new(37.0, 128.0).radians
      end
      should "gives the radius to the with section" do
        scope[:with]["@geodist"].should_equal 0.0...15_000.0
      end
    end

    describe "when a boundingbox is provided" do
      let(:options) do
        {
          boundingbox: { start: { lat: -180, lon: -180 } , end: { lat: 180, lon: 180 } }
        }
        should "gives the midpoints radians to the geo section" do
          scope[:geo].should_equal [0.0, 0.0]
        end
        should "gives the radius to the with section" do
          scope[:with]["@geodist"].should_equal 0.0...15_000.0
        end
    end
  end
end
end
