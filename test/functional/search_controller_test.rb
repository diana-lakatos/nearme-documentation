require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  context 'conduct search' do

    setup do
      stub_request(:get, /.*maps\.googleapis\.com.*/)
      stub_mixpanel
    end

    should "not track search for empty query" do
      @tracker.expects(:conducted_a_search).never
      get :index, :q => nil
    end

    should 'track search for first page' do
      @tracker.expects(:conducted_a_search).once
      get :index, :q => 'adelaide', :page => 1
    end

    should 'not track search for second page' do
      @tracker.expects(:conducted_a_search).never
      get :index, :q => 'adelaide', :page => 2
    end

    should 'log filters in mixpanel along with other arguments' do
      @listing_type = FactoryGirl.create(:listing_type)
      @location_type = FactoryGirl.create(:location_type)
      @industry = FactoryGirl.create(:industry)
      expected_custom_options = {
        search_query: 'adelaide', 
        result_view: 'list', 
        result_count: 0, 
        listing_type_filter: [@listing_type.name], 
        location_type_filter: [@location_type.name], 
        industry_filter: [@industry.name]
      }
      @tracker.expects(:conducted_a_search).with do |search, custom_options|
        expected_custom_options == custom_options
      end
      get :index, { :q => 'adelaide', :listing_types_ids => [@listing_type.id], :location_types_ids => [@location_type.id], :industries_ids => [@industry.id] }
    end

    should 'track search if ignore_search flag is set to 0' do
      @tracker.expects(:conducted_a_search).once
      get :index, :q => 'adelaide', :ignore_search_event => "0"
    end

    should 'not track search if ignore_search flag is set to 1' do
      @tracker.expects(:conducted_a_search).never
      get :index, :q => 'adelaide', :ignore_search_event => "1"
    end

    should 'not track second search for the same query if filters have not been changed' do
      @tracker.expects(:conducted_a_search).once
      Rails.logger.debug 'failingtest'
      get :index, :q => 'adelaide'
      get :index, :q => 'adelaide'
    end

    context 'modified filters' do

      setup do
        @tracker.expects(:conducted_a_search).twice
        get :index, :q => 'adelaide'
      end

      should 'track search if listing filter has been modified' do
        get :index, :q => 'adelaide', :listing_types_ids => [FactoryGirl.create(:listing_type).id]
      end

      should 'track search if location filter has been modified' do
        get :index, :q => 'adelaide', :location_types_ids => [FactoryGirl.create(:location_type).id]
      end

      should 'track search if industry filter has been modified' do
        get :index, :q => 'adelaide', :industries_ids => [FactoryGirl.create(:industry).id]
      end

    end

    should 'not track second search for the different query' do
      @tracker.expects(:conducted_a_search).twice
      get :index, :q => 'adelaide'
      get :index, :q => 'auckland'
    end

  end


  context 'scopes current partner' do

    setup do
      @partner = FactoryGirl.create(:partner)
      PlatformContext.any_instance.stubs(:partner).returns(@partner)
      stub_request(:get, /.*maps\.googleapis\.com.*/)
      stub_mixpanel
    end

    should 'search all listings if no scoping set for current partner' do
      @partner.search_scope_option = 'no_scoping'
      get :index, :q => 'auckland'

      assert_equal Listing.all, assigns(:listings)
    end

    should 'search only associated listings if search scope option set for current partner' do
      @partner.update_attribute(:search_scope_option, 'all_associated_listings')
      @listing = FactoryGirl.create(:listing_in_auckland)
      @listing.company.update_attribute(:partner_id, @partner.id)
      
      get :index, :q => 'auckland'

      assert_equal [@listing], assigns(:listings)
    end

  end

end

