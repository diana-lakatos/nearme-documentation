require 'test_helper'
require 'helpers/search_params_test_helper'
require Rails.root.join('app', 'models', 'listing', 'search', 'errors.rb')
require Rails.root.join('app', 'models', 'listing', 'search', 'params', 'availability.rb')

class Listing::Search::Params::ApiTest <  ActiveSupport::TestCase
  include SearchParamsTestHelper
  context "#new" do
    should "Raise SearchTypeNotSupported when created with neither query, nor bounding box" do
      assert_raise Listing::Search::SearchTypeNotSupported do
        Listing::Search::Params::Api.new({})
      end
    end
  end

  def build_params(options)
    Listing::Search::Params::Api.new(options)
  end

end
