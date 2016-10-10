require 'test_helper'
require 'helpers/search_params_test_helper'
require Rails.root.join('app', 'models', 'listing', 'search', 'errors.rb')

class Listing::Search::Params::ApiParamsTest < ActiveSupport::TestCase
  include SearchParamsTestHelper
  context '#new' do
    should 'Raise SearchTypeNotSupported when created with neither query, nor bounding box' do
      assert_raise Listing::Search::SearchTypeNotSupported do
        Listing::Search::Params::ApiParams.new({}, TransactableType.first)
      end
    end
  end

  def build_params(options)
    Listing::Search::Params::ApiParams.new(options, TransactableType.first)
  end
end
