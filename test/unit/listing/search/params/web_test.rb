require 'test_helper'
require 'helpers/search_params_test_helper'
class Listing::Search::Params::WebTest <  ActiveSupport::TestCase
  include SearchParamsTestHelper

  context '#keyword_search?' do
    should "return false regardless of whether a query is set" do
      params = build_params(options_with_query, fake_geocoder(false))
      assert params.query.present?, params.inspect
      assert !params.keyword_search?

      params = build_params(options_with_query(nil), fake_geocoder(false))
      assert params.query.blank?
      assert !params.keyword_search?
    end
  end

  context '#bounding_box' do
    should "use nx,ny,sx,sy parameters instead of defaults" do
      params = build_params(options_with_bounding_box({ :nx => 0, :ny => 0.5, :sx => -0.5, :sy => 1 }))
      assert_equal [0, 0.5, -0.5, 1], params.provided_boundingbox
    end
  end

  context '#provided_midpoint' do
    should 'use lat,lng parameters instead of defaults' do
      params = build_params(options_with_midpoint({ :lat => -1, :lng => 1 }))
      assert_equal [-1, 1], params.provided_midpoint
    end
  end

  def build_params(options, geocoder = fake_geocoder(true))
    Listing::Search::Params::Web.new(options, geocoder)
  end

end
