require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  setup do
    stub_request(:get, /.*maps\.googleapis\.com.*/)
    stub_mixpanel
  end

  def assert_nothing_found
    assert_select 'h1', 1, 'No results found'
    assert_select 'p', 1, "The address you entered couldn't be found"
  end

  def assert_location_in_result(location)
    location.listings.each do |listing|
      assert_select 'article[data-id=?]', listing.id, count: 1
    end
  end

  def refute_location_in_result(location)
    location.listings.each do |listing|
      assert_select 'article[data-id=?]', listing.id, count: 0
    end
  end

  context 'search integration' do
    setup do
      Location.destroy_all
    end

    context 'for disabled listing' do
      should 'exclude disabled listing' do
        location = @auckland = FactoryGirl.create(:location_in_auckland)
        location.listings.each do |listing|
          listing.update_attribute(:enabled, false)
        end

        get :index, q: 'Auckland'
        assert_nothing_found
      end
    end

    context 'for invalid place' do
      should 'find nothing for empty query' do
        get :index, q: ''
        assert_nothing_found
      end

      should 'find nothing for invalid query' do
        get :index, q: 'bung'
        assert_nothing_found
      end
    end

    context 'for unavailable listings' do
      should 'display also unavailable listings' do
        unavaliable_location = FactoryGirl.create(:fully_booked_listing_in_cleveland).location
        available_location = FactoryGirl.create(:listing_in_cleveland).location

        get :index, q: 'Cleveland'

        assert_location_in_result(unavaliable_location) 
        assert_location_in_result(available_location)
      end
    end

    context 'for existing location' do
      context 'with industry filter' do
        should 'filter only filtered locations' do
          filtered_industry = FactoryGirl.create(:industry)
          another_industry = FactoryGirl.create(:industry)
          filtered_auckland = FactoryGirl.create(:company, industries: [filtered_industry], locations: [FactoryGirl.create(:location_in_auckland)]).locations.first
          another_auckland = FactoryGirl.create(:company, industries: [another_industry], locations: [FactoryGirl.create(:location_in_auckland)]).locations.first

          get :index, { :q => 'Auckland', :industries_ids => [filtered_industry.id] }

          assert_location_in_result(filtered_auckland) 
          refute_location_in_result(another_auckland) 
        end
      end

      context 'with location type filter' do
        should 'filter only filtered locations' do
          filtered_location_type = FactoryGirl.create(:location_type)
          another_location_type = FactoryGirl.create(:location_type)
          filtered_auckland = FactoryGirl.create(:location_in_auckland, location_type: filtered_location_type)
          another_auckland = FactoryGirl.create(:location_in_auckland, location_type: another_location_type)

          get :index, { :q => 'Auckland', :location_types_ids => [filtered_location_type.id] }

          assert_location_in_result(filtered_auckland) 
          refute_location_in_result(another_auckland) 
        end
      end

      context 'with listing type filter' do
        should 'filter only filtered locations' do
          filtered_listing_type = FactoryGirl.create(:listing_type)
          another_listing_type = FactoryGirl.create(:listing_type)
          filtered_auckland = FactoryGirl.create(:listing_in_auckland, listing_type: filtered_listing_type).location
          another_auckland = FactoryGirl.create(:listing_in_auckland, listing_type: another_listing_type).location

          get :index, { :q => 'Auckland', :listing_types_ids => [filtered_listing_type.id] }

          assert_location_in_result(filtered_auckland) 
          refute_location_in_result(another_auckland) 
        end
      end

      context 'without filter' do
        context 'show only valid locations' do
          setup do
            @auckland = FactoryGirl.create(:location_in_auckland)
            @adelaide = FactoryGirl.create(:location_in_adelaide)
          end

          should 'in map view' do
            get :index, q: 'Adelaide', v: 'map'
            assert_location_in_result(@adelaide) 
            refute_location_in_result(@auckland) 
          end

          context 'in list view' do

            should 'show results' do
              get :index, q: 'Adelaide', v: 'list'
              assert_location_in_result(@adelaide) 
              refute_location_in_result(@auckland) 
            end

            context 'connections' do
              setup do
                @me = FactoryGirl.create(:user)
                @friend = FactoryGirl.create(:user)
                @me.add_friend(@friend)

                FactoryGirl.create(:past_reservation, listing: FactoryGirl.create(:listing, location: @adelaide), user: @friend, state: 'confirmed')
              end

              should 'are shown for logged user' do
                sign_in(@me)
                @me.stubs(:unread_messages_count).returns(0)

                get :index, q: 'Adelaide', v: 'list'

                assert_select '[title=?]', "#{@friend.name} worked here"
              end

              should 'are hidden for guests' do
                sign_out(@me)

                get :index, q: 'Adelaide', v: 'list'

                assert_select '[title=?]', "#{@friend.name} worked here", 0
              end
            end
          end
        end
      end
    end
  end

  context 'conduct search' do


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

