require 'test_helper'
require 'helpers/search_params_test_helper'
class Listing::Search::ParamsTest <  ActiveSupport::TestCase
  include SearchParamsTestHelper

  describe "#query" do
    
    context "when coordinates are not provided" do
      
      should "keep the query when created with a query that is not found" do
        assert_equal "not_found_location", build_params(options_with_query("not_found_location"), fake_geocoder(false)).query
      end

      should "remove the query when created with a query that was found" do
        assert_equal nil, build_params(options_with_query(nil), fake_geocoder(true)).query
      end
      
    end
    
    context "when coordinates are provided" do
      
      should "keeps the query if the query is not found" do
        assert_equal "not_found_location", build_params(options_with_location.merge(options_with_query("not_found_location")), fake_geocoder(false)).query
      end
      
    end
    
  end

  describe '#keyword_search?' do
    
    should "return true if there is a query" do
      params = build_params(options_with_location(options_with_query), fake_geocoder)
      assert params.query.present?
      assert params.keyword_search?
    end

    should "return false if there is no query" do
      params = build_params(options_with_location(options_with_query(nil)), fake_geocoder(false))
      assert params.query.blank?
      assert !params.keyword_search?
    end
    
  end
  
  describe '#radius' do
    
    context 'with a bounding_box' do
      
      setup do
        options = options_with_bounding_box
        @bounding_box = [options[:boundingbox][:start].values, options[:boundingbox][:end].values]
        @params = build_params(options_with_bounding_box, fake_geocoder)
      end
      
      should 'provide a radius between nx and sy' do
        expecred_radius = Geocoder::Calculations.distance_between(*@bounding_box) / 2
        assert_equal @params.radius, expecred_radius
      end
      
    end
    
    context 'with a midpoint' do
      
      setup do
        @params = build_params(options_with_location, fake_geocoder)
      end
      
      should 'provide the default radius' do
        assert_equal @params.radius, Listing::Search::Params::DEFAULT_SEARCH_RADIUS
      end
      
    end
    
  end
  
  describe '#midpoint' do
    
    context 'with a bounding_box' do
      
      setup do
        options = options_with_bounding_box
        @bounding_box = [options[:boundingbox][:start].values, options[:boundingbox][:end].values]
        @params = build_params(options_with_bounding_box, fake_geocoder)
      end
      
      should 'provide a midpoint between nx and sy' do
        expecred_midpoint = Geocoder::Calculations.geographic_center(bounding_box)
        assert_equal @params.midpoint, expecred_midpoint
      end
      
    end
    
    context 'with a location' do
      
      setup do
        options = options_with_location
        @expected_midpoint = options[:location].values
        @params = build_params(options, fake_geocoder)
      end
      
      should 'provide the expected midpoint' do
        assert_equal @params.midpoint, @expected_midpoint
      end
      
    end
    
  end
  
  describe '#bounding_box' do
    
    context 'with a provided bounding box' do
      
      setup do
        options = options_with_bounding_box
        @expected_bounding_box = [options[:boundingbox][:start].values, options[:boundingbox][:end].values]
        @params = build_params(options_with_bounding_box, fake_geocoder)
      end
      
      should 'provide the correct representation of what was given' do
        assert_equal @params.midpoint, @expected_bounding_box
      end
      
    end
    
  end
  
  describe '#found_location?' do
    
    context 'with an empty geocode' do
      
      setup do
        @params = build_params(options_with_query("not_found_location"), fake_geocoder(false))
      end
      
      should 'return false' do
        assert @params.found_location? == false
      end
      
    end
    
    context 'with a successful geocode' do
      
      setup do
        @params = build_params(options_with_query, fake_geocoder)
      end
      
      should 'return true' do
        assert @params.found_location?
      end
      
    end
    
  end
  
  describe '#to_args' do
  
    context "when a query is found" do
      
      setup do
        @result = args_for(options_with_query, fake_geocoder)
      end
      
      should "provide midpoint for location"  do
        assert_equal @result[0], midpoint
      end
      
      should "provide radius for location" do
        assert_equal @result[1], radius
      end
      
      context "and a bounding box is provided" do
        
        setup do
          @geocoder = fake_geocoder
          @result = args_for(options_with_bounding_box.merge(options_with_query("found_location")), @geocoder)
        end
        
        should "should not trigger the geocoder" do
          @geocoder.expects(:find_search_area).never
          assert @result.present?
        end
      end
    end
    
    context "when a query is not found" do
      should "args should be nil" do
        args = args_for(options_with_query, fake_geocoder(false))
        assert args.nil?
      end
    end
    
    context "when a boundingbox is provided" do
      
      setup do
        options = options_with_bounding_box
        bounding_box = [options[:boundingbox][:start].values, options[:boundingbox][:end].values]
        
        @result = args_for(options, fake_geocoder(false))
        
        @expected_midpoint = Geocoder::Calculations.geographic_center(bounding_box)
        @expected_radius = Geocoder::Calculations.distance_between(*bounding_box) / 2
      end
      
      should "gives the midpoint to the geo section" do
        assert_equal @expected_midpoint, @result[0]
      end
  
      should "gives the radius to the with section" do
        assert_equal @expected_radius, @result[1]
      end
    end
  end
  
  private
  
  def build_params(options, geocoder)
    Listing::Search::Params.new(options, geocoder)
  end
end
