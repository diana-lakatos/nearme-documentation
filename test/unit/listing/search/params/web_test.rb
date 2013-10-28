require 'test_helper'
require 'helpers/search_params_test_helper'

class Listing::Search::Params::WebTest <  ActiveSupport::TestCase
  include SearchParamsTestHelper

  context '#bounding_box' do
    should "use nx,ny,sx,sy parameters instead of defaults" do
      params = build_params(options_with_bounding_box({ :nx => 0, :ny => 0.5, :sx => -0.5, :sy => 1 }))
      assert_equal [[0, 0.5], [-0.5, 1]], params.bounding_box
    end
  end

  context '#midpoint' do
    should 'use lat,lng parameters instead of defaults' do
      params = build_params(options_with_location({ location: { :lat => -1, :lon => 1 } }))
      assert_equal [-1, 1], params.midpoint
    end
  end

  def build_params(options)
    Listing::Search::Params::Web.new(options)
  end

end
