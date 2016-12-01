require 'test_helper'

class InstanceType::Searcher::Elastic::GeolocationSearcher::ListingTest < ActiveSupport::TestCase
  context 'with ES instance' do
    setup do
      stub_request(:get, /.*maps\.googleapis\.com.*/).to_return(status: 404, body: {}.to_json, headers: {})
      @class_test = InstanceType::Searcher::Elastic::GeolocationSearcher::Listing
      Transactable.destroy_all
      enable_elasticsearch! do
        @public_location_type = FactoryGirl.create(:location_type, name: 'public')
        @private_location_type = FactoryGirl.create(:location_type, name: 'private')

        @public_location = FactoryGirl.create(:location, location_type: @public_location_type, location_address: FactoryGirl.build(:address, latitude: 5, longitude: 5))
        @private_location = FactoryGirl.create(:location, location_type: @private_location_type, location_address: FactoryGirl.build(:address, latitude: 10, longitude: 10))

        @public_listing_type = 'Desk'
        @private_listing_type = 'Meeting Room'
        @office_listing_type = 'Office Space'

        @public_listing = FactoryGirl.create(:transactable, properties: { listing_type: @public_listing_type }, location: @public_location)
        @public_office_listing = FactoryGirl.create(:transactable, properties: { listing_type: @office_listing_type }, location: @public_location)
        @private_listing = FactoryGirl.create(:transactable, properties: { listing_type: @private_listing_type }, location: @private_location)
        @private_office_listing = FactoryGirl.create(:transactable, properties: { listing_type: @office_listing_type }, location: @private_location)

        @public_listing_other_tt = FactoryGirl.create(:transactable, transactable_type: FactoryGirl.create(:transactable_type), properties: { listing_type: @public_listing_type }, location: @public_location)

        @free_listing = FactoryGirl.create(:transactable, :free_listing)

        @filters = { lat: 5, lng: 5, transactable_type_id: TransactableType.first.id }
      end
    end

    teardown do
      disable_elasticsearch!
    end

    should 'return result for right transactable type' do
      @public_listing_other_tt.transactable_type.search_radius = 100_000
      assert_equal [@public_listing_other_tt], @class_test.new(@public_listing_other_tt.transactable_type, @filters.merge(transactable_type_id: @public_listing_other_tt.transactable_type_id)).invoke.sort
    end

    context '#geolocation' do
      should 'find locations near midpoint or return all if no lat/lon' do
        filters = @filters.merge(lat: 5, lng: 6, loc: true)
        assert_equal [@public_listing, @public_office_listing].sort, @class_test.new(@public_listing.transactable_type, filters).invoke.sort
        filters = @filters.merge(lat: nil, lng: nil)
        assert_equal [@public_listing, @public_office_listing, @private_listing, @private_office_listing, @free_listing].map(&:id), @class_test.new(@public_listing.transactable_type, filters).invoke.map(&:id)
      end
    end

    context 'filters' do
      setup do
        @filters.merge!(lat: nil, lng: nil)
      end

      should 'find location with specified filters' do
        filters = @filters.merge(location_types_ids: [@public_location_type.id])
        assert_equal [@public_listing, @public_office_listing].sort, @class_test.new(@public_listing.transactable_type, filters).invoke.sort
        filters = @filters.merge(lg_custom_attributes: { listing_type: 'Shared Something' })
        assert_equal [], @class_test.new(@public_listing.transactable_type, filters).invoke
      end

      context 'price type' do
        should 'find listings by price type' do
          filters = @filters.merge(lgpricing: '0_free')
          assert @class_test.new(@public_listing.transactable_type, filters).invoke.any?
          filters = @filters.merge(lgpricing: '1_day')
          assert @class_test.new(@public_listing.transactable_type, filters).invoke.any?
          filters = @filters.merge(lgpricing: '7_day')
          assert @class_test.new(@public_listing.transactable_type, filters).invoke.none?
        end
      end
    end
  end

  context 'with es stubbed' do
    setup do
      stub_request(:get, /.*localhost:9200.*/).to_return(status: 200, body: '')
      @transactable_type = build(:transactable_type_listing, searcher_type: 'geo')
      @search_web_params = ::Listing::Search::Params::Web.new({}, @transactable_type)
      @searcher = InstanceType::Searcher::Elastic::GeolocationSearcher::Listing.new(@transactable_type, {})
      @searcher.stubs(:search).returns(@search_web_params)
    end

    should 'use "geo_search" when map is moved' do
      @searcher.instance_variable_set(:@params, map_moved: 'true')
      @searcher.expects(:extend_params_by_geo_filters)
      @searcher.fetcher
    end

    should 'use "geo_search" when located' do
      @searcher.search.instance_variable_set(:@options, lat: 123, lng: 123)
      @searcher.expects(:extend_params_by_geo_filters)
      @searcher.fetcher
    end

    should 'use geo distance query when address is located' do
      @searcher.search.instance_variable_set(:@options, lat: 123, lng: 123)
      @searcher.instance_variable_set(:@params, lat: 123, lng: 123)
      @searcher.fetcher

      params = @searcher.instance_variable_get(:@search_params)
      assert params.key?(:lat)
      assert params.key?(:lng)
      assert params.key?(:distance)
    end

    should 'use bounding_box query when map is moved' do
      @searcher.instance_variable_set(:@params, map_moved: 'true')
      @searcher.fetcher

      params = @searcher.instance_variable_get(:@search_params)
      assert params.key?(:bounding_box)
    end

    should 'use geo distance query when address is not precise but service radius is enabled' do
      @searcher.instance_variable_set(:@params, lat: 123, lng: 123)
      @searcher.search.instance_variable_set(:@options, lat: 123, lng: 123)
      @searcher.stubs(:service_radius_enabled?).returns(true)
      @search_web_params.stubs(:precise_address?).returns(false)
      @search_web_params.stubs(:bounding_box).returns({ top_right: { lat: 123, lon: 123}, bottom_left: { lat: 123, lon: 123 }})

      @searcher.fetcher

      params = @searcher.instance_variable_get(:@search_params)
      assert params.key?(:lat)
      assert params.key?(:lng)
      assert params.key?(:distance)
    end
  end
end
