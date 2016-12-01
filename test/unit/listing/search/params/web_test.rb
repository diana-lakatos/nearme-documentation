require 'test_helper'
require 'helpers/search_params_test_helper'

class Listing::Search::Params::WebTest < ActiveSupport::TestCase
  include SearchParamsTestHelper

  context '#bounding_box' do
    should 'use nx,ny,sx,sy parameters instead of defaults' do
      params = build_params(options_with_bounding_box(nx: 0, ny: 0.5, sx: -0.5, sy: 1))
      expected_box = { bottom_left: { lat: -0.5, lon: 1 }, top_right: { lat: 0, lon: 0.5 }}
      assert_equal expected_box, params.bounding_box
    end
  end

  context '#midpoint' do
    should 'use lat,lng parameters instead of defaults' do
      params = build_params(options_with_location(location: { lat: -1, lon: 1 }))
      assert_equal [-1, 1], params.midpoint
    end
  end

  context '#precise_address?' do
    should 'return true when state and city are present' do
      params = build_params(state: 'State', city: 'City')
      assert_equal(true, params.precise_address?)
    end
  end

  def build_params(options)
    Listing::Search::Params::Web.new(options, TransactableType.first)
  end
end
