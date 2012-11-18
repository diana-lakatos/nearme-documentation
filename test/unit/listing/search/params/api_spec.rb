require './test/unit/listing/helper.rb'
require './app/models/listing/search/params/api'
require './app/models/listing/search/params'
require './app/models/listing/search/errors'
require './app/models/listing/search/area'
require './app/models/listing/search/params/availability'
require './app/models/coordinate'
require './app/models/null_user'
require './app/models/price_range'
require './app/models/null_price_range'
require 'active_support'

describe Listing::Search::Params::Api do
  include Mocha::Integration::MiniTest
  let(:params) { Listing::Search::Params::Api.new(options, geocoder) }
  let(:geocoder) { stub("Geocoder", find_location: false) }

  describe "#new" do
    describe "when created with neither query, nor bounding box" do
      it "Raises SearchTypeNotSupported" do
        proc do
          Listing::Search::Params::Api.new({}, geocoder)
        end.must_raise Listing::Search::SearchTypeNotSupported
      end
    end
  end

  describe("#query") do
    describe "when created with a query that is not found" do
      let(:options) { { query: "not_found_location" } }
      it "keeps the query" do params.query.must_equal "not_found_location" end
    end

    describe "When created with a query that was found" do
      let(:options) { { query: "found_location" } }
      let(:geocoder) { stub({ find_location: true }) }
      it "removes the query" do params.query.must_equal nil end
    end
  end
  describe "#to_scope" do
    let(:scope) { params.to_scope }
    let(:options) { { query: "asdf" } }
    it "never includes deleted items" do
      scope[:with][:deleted_at].must_equal 0
    end

    it "always includes an organization id of 0" do
      scope[:with][:organization_ids].must_equal [0]
    end

    describe "when a user is provided" do
      let(:options) { { query: "asdf", user: Struct.new(:organization_ids).new([1,2,3]) } }
      it "includes the organization ids in the with section" do
        scope[:with][:organization_ids].must_equal [1,2,3,0]
      end
    end

    describe "when a query is found" do
      let(:geocoder) { stub({find_location: search_area}) }
      let(:search_area) { Listing::Search::Area.new(midpoint, 5.0) }
      let(:midpoint) { Coordinate.new(1,1) }

      it "gives the locations radians to the geo section"  do
        scope[:geo].must_equal midpoint.radians
      end
      it "gives the radius to the with section" do
        scope[:with]["@geodist"].must_equal 0.0...5.0
      end
    end

    describe "when a query is not found" do

      it "does not include the @geodist in with" do
        scope[:with].has_key?("@geodist").must_equal false
      end
      it "does not set the geo value" do
        scope.has_key?(:geo).must_equal false
      end
    end

    describe "when a center is provided" do
      let(:options) { { location: { lat: 37.0, lon: 128.0 } } }
      it "gives the midpoints radians to the geo section" do
        scope[:geo].must_equal Coordinate.new(37.0, 128.0).radians
      end
      it "gives the radius to the with section" do
        scope[:with]["@geodist"].must_equal 0.0...15_000.0
      end
    end

    describe "when a boundingbox is provided" do
      let(:options) do
        {
          boundingbox: { start: { lat: -180, lon: -180 } , end: { lat: 180, lon: 180 } }
        }
        it "gives the midpoints radians to the geo section" do
          scope[:geo].must_equal [0.0, 0.0]
        end
        it "gives the radius to the with section" do
          scope[:with]["@geodist"].must_equal 0.0...15_000.0
        end
    end
  end
end
end
