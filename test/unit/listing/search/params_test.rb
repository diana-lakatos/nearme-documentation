require 'test_helper'
require 'helpers/search_params_test_helper'
class Listing::Search::ParamsTest <  ActiveSupport::TestCase
  include SearchParamsTestHelper

  context '#radius' do
    context 'with a bounding_box' do
      setup do
        options = options_with_bounding_box
        @bounding_box = [options[:boundingbox][:start].values, options[:boundingbox][:end].values]
        @params = build_params(options_with_bounding_box)
      end

      should 'provide a radius between nx and sy' do
        expecred_radius = Geocoder::Calculations.distance_between(*@bounding_box) / 2
        assert_equal @params.radius, expecred_radius
      end
    end

    context 'with a midpoint' do
      setup do
        @params = build_params(options_with_location)
      end

      should 'provide the default radius' do
        assert_equal @params.radius, Listing::Search::Params::DEFAULT_SEARCH_RADIUS
      end
    end
  end

  context '#midpoint' do
    context 'with a bounding_box' do
      setup do
        options = options_with_bounding_box
        @bounding_box = [options[:boundingbox][:start].values, options[:boundingbox][:end].values]
        @params = build_params(options_with_bounding_box)
      end

      should 'provide a midpoint between nx and sy' do
        expected_midpoint = Geocoder::Calculations.geographic_center(@bounding_box)
        assert_equal expected_midpoint, @params.midpoint
      end
    end

    context 'with a location' do
      setup do
        options = options_with_location
        @expected_midpoint = options[:location].values
        @params = build_params(options)
      end

      should 'provide the expected midpoint' do
        assert_equal @expected_midpoint, @params.midpoint
      end
    end
  end

  context '#bounding_box' do
    context 'with a provided bounding box' do
      setup do
        options = options_with_bounding_box
        @expected_bounding_box = [options[:boundingbox][:start].values, options[:boundingbox][:end].values]
        @params = build_params(options_with_bounding_box)
      end

      should 'provide the correct representation of what was given' do
        assert_equal @expected_bounding_box, @params.bounding_box
      end
    end
  end

  private

  def build_params(options)
    Listing::Search::Params.new(options)
  end
end
