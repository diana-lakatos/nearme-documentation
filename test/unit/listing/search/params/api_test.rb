require 'test_helper'

class Listing::Search::Params::ApiTest <  ActiveSupport::TestCase
  context "#new" do
    should "Raise SearchTypeNotSupported when created with neither query, nor bounding box" do
      assert_raise Listing::Search::SearchTypeNotSupported do
        Listing::Search::Params::Api.new({}, fake_geocoder(false))
      end
    end
  end

  context "#query" do
    should "keep the query when created with a query that is not found" do
      assert_equal "not_found_location", build_params(options_with_query("not_found_location"), fake_geocoder(false)).query
    end

    should "remove the query when created with a query that was found" do
      assert_equal nil, build_params(options_with_query, fake_geocoder(true)).query
    end
  end

  context "#to_scope" do

    should "never include deleted items" do
      scope = scope_for(options_with_query, fake_geocoder(false))
      assert_equal scope[:with][:deleted_at], 0
    end

    should "always includes an organization id of 0" do
      scope = scope_for(options_with_query, fake_geocoder(false))
      assert_equal scope[:with][:organization_ids], [0]
    end

    context "when a user is provided" do
      should "includes the organization ids in the with section" do
        options = { query: "asdf", user: Struct.new(:organization_ids).new([1,2,3]) }
        scope = scope_for(options, fake_geocoder(false))
        assert_equal scope[:with][:organization_ids], [1,2,3,0]
      end
    end

    context "when a query is found" do
       should "gives the locations radians to the geo section"  do
        scope = scope_for(options_with_query, fake_geocoder(search_area))
        assert_equal scope[:geo], midpoint.radians
      end

      should "gives the radius to the with section" do
        scope = scope_for(options_with_query, fake_geocoder(search_area))
        assert_equal scope[:with]["@geodist"], 0.0...5.0
      end

     end
      context "when a query is not found" do
        should "does not include the @geodist in with" do
          scope = scope_for(options_with_query, fake_geocoder(false))
          refute scope[:with].has_key? "@geodist"
        end

        should "does not set the geo value" do
          scope = scope_for(options_with_query, fake_geocoder(false))
          refute scope.has_key? :geo
        end
      end

      context "when a center is provided" do
        should "gives the midpoints radians to the geo section" do
          scope = scope_for(options_with_midpoint, fake_geocoder(false))
          assert_equal scope[:geo], midpoint.radians
        end
        should "gives the radius to the with section" do
          scope = scope_for(options_with_midpoint, fake_geocoder(false))
          assert_equal scope[:with]["@geodist"], 0.0...15_000.0
        end
      end

      context "when a boundingbox is provided" do
        should "gives the midpoints radians to the geo section" do
          scope = scope_for(options_with_bounding_box, fake_geocoder(false))
          assert_equal [0.25151695675404967, 0.06546623544501572], scope[:geo]
        end

        should "gives the radius to the with section" do
          scope = scope_for(options_with_bounding_box, fake_geocoder(false))
          assert_equal 0.0...977008.5143096122, scope[:with]["@geodist"]
        end
      end
    end

  def build_params(options, geocoder)
    Listing::Search::Params::Api.new(options, geocoder)
  end

  def fake_geocoder(finds_result)
    stub("Geocoder", find_location: finds_result)
  end

  def options_with_bounding_box
    { boundingbox: { start: { lat: 10, lon:-10 } , end: { lat: 18, lon: 18 } } }
  end

  def options_with_midpoint
    { location: { lat: 37.0, lon: 128.0 } }
  end

  def search_area
    Listing::Search::Area.new(midpoint, 5.0)
  end

  def midpoint
    Coordinate.new(37.0, 128.0)
  end

  def scope_for(options, geocoder)
    Listing::Search::Params::Api.new(options, geocoder).to_scope
  end

  def options_with_query(query='asdf')
    { query: query }
  end

end
