require 'test_helper'

class InstanceType::Searcher::Elastic::GeolocationSearcher::ListingTest < ActiveSupport::TestCase

  setup do
    stub_request(:get, /.*localhost:9200.*/).to_return(status: 200, body: '')
    @transactable_type = build(:transactable_type_listing)
    @search_web_params = ::Listing::Search::Params::Web.new({}, @transactable_type)
    @searcher = InstanceType::Searcher::Elastic::GeolocationSearcher::Listing.new(@transactable_type, {})
    @searcher.stubs(:search).returns(@search_web_params)
  end

  test 'use "geo_search" when map is moved' do
    @searcher.instance_variable_set(:@params, {map_moved: 'true'})
    @searcher.expects(:extend_params_by_geo_filters)
    @searcher.fetcher
  end

  test 'use "geo_search" when located' do
    @searcher.instance_variable_set(:@params, {lat: 123, lng: 123})
    @searcher.expects(:extend_params_by_geo_filters)
    @searcher.fetcher
  end

  test 'use geo distance query when address is located' do
    @searcher.instance_variable_set(:@params, {lat: 123, lng: 123})
    @searcher.fetcher

    params = @searcher.instance_variable_get(:@search_params)
    assert params.has_key?(:lat)
    assert params.has_key?(:lng)
    assert params.has_key?(:distance)
  end

  test 'use bounding_box query when map is moved' do
    @searcher.instance_variable_set(:@params, {map_moved: 'true'})
    @searcher.fetcher

    params = @searcher.instance_variable_get(:@search_params)
    assert params.has_key?(:bounding_box)
  end

  test 'use geo distance query when address is not precise but service radius is enabled' do
    @searcher.instance_variable_set(:@params, {lat: 123, lng: 123})
    @searcher.stubs(:service_radius_enabled?).returns(true)
    @search_web_params.stubs(:precise_address?).returns(false)
    @search_web_params.stubs(:bounding_box).returns([[123,123], [123,123]])

    @searcher.fetcher

    params = @searcher.instance_variable_get(:@search_params)
    assert params.has_key?(:lat)
    assert params.has_key?(:lng)
    assert params.has_key?(:distance)
  end

end
