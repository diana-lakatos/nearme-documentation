require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  setup do
    stub_request(:get, /.*maps\.googleapis\.com.*/).to_return(status: 404, body: {}.to_json, headers: {})
    enable_elasticsearch!
  end

  teardown do
    disable_elasticsearch!
  end

  context 'for anything when no TransactableType exists' do
    setup do
      TransactableType.destroy_all
    end

    should 'redirect to homepage' do
      get :index, loc: 'Anywhere'
      assert_redirected_to root_path
    end
  end

  context 'for transactable type listing' do
    setup do
      FactoryGirl.create(:transactable_type_listing)
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

          get :index, loc: 'Auckland'
          assert_nothing_found
        end
      end

      context 'for invalid place' do
        should 'find nothing for invalid query' do
          get :index, loc: 'bung'
          assert_nothing_found
        end
      end

      context 'for unavailable listings' do
        should 'display also unavailable listings' do
          FactoryGirl.create(:manual_payment_gateway)
          unavaliable_location = FactoryGirl.create(:fully_booked_listing_in_cleveland).location
          available_location = FactoryGirl.create(:listing_in_cleveland).location

          get :index, loc: 'Cleveland', v: 'mixed'

          assert_location_in_mixed_result(unavaliable_location)
          assert_location_in_mixed_result(available_location)
        end
      end

      context 'for existing location' do
        context 'with location type filter' do
          should 'filter only filtered locations' do
            filtered_location_type = FactoryGirl.create(:location_type)
            another_location_type = FactoryGirl.create(:location_type)
            filtered_auckland = FactoryGirl.create(:location_in_auckland, location_type: filtered_location_type)
            another_auckland = FactoryGirl.create(:location_in_auckland, location_type: another_location_type)

            get :index, loc: 'Auckland', lntype: filtered_location_type.id, v: 'mixed'

            assert_location_in_result(filtered_auckland)
            refute_location_in_result(another_auckland)
          end
        end

        context 'with listing type filter' do
          should 'filter only filtered locations' do
            filtered_listing_type = 'Desk'
            another_listing_type = 'Meeting Room'
            service_type = TransactableType.first || FactoryGirl.create(:transactable_type_listing)
            filtered_auckland = FactoryGirl.create(:listing_in_auckland, transactable_type: service_type, properties: { listing_type: filtered_listing_type }).location
            another_auckland = FactoryGirl.create(:listing_in_auckland, transactable_type: service_type, properties: { listing_type: another_listing_type }).location

            get :index, loc: 'Auckland', lg_custom_attributes: { 'listing_type' => [filtered_listing_type] }, v: 'mixed'

            assert_location_in_mixed_result(filtered_auckland)
            refute_location_in_mixed_result(another_auckland)
          end
        end

        context 'with attribute value filter' do
          should 'filter only filtered locations' do
            FactoryGirl.create(:custom_attribute, target: TransactableType.first, attribute_type: 'string', name: 'filterable_attribute', searchable: true, valid_values: %w(Righthanded Lefthanded))
            listing = FactoryGirl.create(:listing_in_cleveland, photos_count: 1, properties: { filterable_attribute: 'Lefthanded' })
            filtered_auckland = listing.location

            another_auckland = FactoryGirl.create(:listing_in_cleveland, properties: { filterable_attribute: ['Righthanded'] }).location
            get :index, loc: 'Cleveland', lg_custom_attributes: { filterable_attribute: ['Lefthanded'] }, v: 'mixed'

            assert_location_in_mixed_result(filtered_auckland)
            refute_location_in_mixed_result(another_auckland)
          end
        end

        context 'with category filter' do
          setup do
            @filtered_category = FactoryGirl.create(:category, name: 'Desk')
            @filtered_category_child = FactoryGirl.create(:category, name: 'Standing Desk', parent: @filtered_category)
            @another_category = FactoryGirl.create(:category, name: 'Meeting Room')
            @filtered_auckland_1 = FactoryGirl.create(:listing_in_auckland, category_ids: ["[#{@filtered_category.id}, #{@another_category.id}]"]).location
            @filtered_auckland_2 = FactoryGirl.create(:listing_in_auckland, category_ids: ["[#{@filtered_category_child.id}]"]).location
            @another_auckland = FactoryGirl.create(:listing_in_auckland, category_ids: ["[#{@another_category.id}]"]).location
          end

          should 'filter only filtered locations when "OR" search mode' do
            TransactableType.first.update_attribute(:category_search_type, 'OR')
            get :index, loc: 'Auckland', category_ids: @filtered_category.id, v: 'mixed', buyable: false
            assert_location_in_mixed_result(@filtered_auckland_1)
            assert_location_in_mixed_result(@filtered_auckland_2)
            refute_location_in_mixed_result(@another_auckland)
          end

          should 'filter only filtered locations when "AND" search mode' do
            TransactableType.first.update_attribute(:category_search_type, 'AND')
            get :index, loc: 'Auckland', category_ids: "#{@filtered_category.id},#{@another_category.id}", v: 'mixed', buyable: false
            assert_location_in_mixed_result(@filtered_auckland_1)
            refute_location_in_mixed_result(@filtered_auckland_2)
            refute_location_in_mixed_result(@another_auckland)
          end
        end

        context 'without filter' do
          context 'show only valid locations' do
            setup do
              @auckland = FactoryGirl.create(:location_in_auckland)
              @adelaide = FactoryGirl.create(:location_in_adelaide)
            end

            should 'in map view' do
              get :index, loc: 'Adelaide', v: 'map'
              assert_location_in_result(@adelaide)
              refute_location_in_result(@auckland)
            end

            should 'in mixed view' do
              get :index, loc: 'Adelaide', v: 'mixed'
              assert_location_in_result(@adelaide)
              refute_location_in_result(@auckland)
            end

            context 'in list view' do
              should 'show results' do
                get :index, loc: 'Adelaide', v: 'list'
                assert_location_in_result(@adelaide)
                refute_location_in_result(@auckland)
              end

              context 'connections' do
                setup do
                  @me = FactoryGirl.create(:user)
                  @friend = FactoryGirl.create(:user)
                  @me.add_friend(@friend)

                  FactoryGirl.create(:past_reservation, transactable: FactoryGirl.create(:transactable, :with_time_based_booking, location: @adelaide), user: @friend)
                  @adelaide.reload
                  Transactable.__elasticsearch__.refresh_index!
                end

                should 'are shown for logged user' do
                  sign_in(@me)
                  @me.stubs(:unread_messages_count).returns(0)
                  get :index, v: 'list', transactable_type_id: @adelaide.listings.first.transactable_type_id
                  assert_select '.connections[rel=?]', 'tooltip', 1
                  assert_select '[title=?]', "#{@friend.name} worked here"
                end

                should 'are hidden for guests' do
                  sign_out(@me)

                  get :index, loc: 'Adelaide', v: 'list'

                  assert_select '.connections[rel=?]', 'tooltip', 0
                end
              end
            end
          end
        end
      end
    end

    context 'conduct search' do
      context 'for fulltext golocation' do
        setup do
          @adelaide = FactoryGirl.create(:listing_in_adelaide)
          @adelaide_super = FactoryGirl.create(:listing_in_adelaide)
          @adelaide_super.description = 'super location'
          @adelaide_super.save
          @adelaide.transactable_type.update_attribute(:searcher_type, 'fulltext_geo')
        end

        context 'on mixed results page' do
          should 'return only super location' do
            get :index, loc: 'adelaide', query: 'super', v: 'mixed'
            assert_transactable_in_mixed_result(@adelaide_super)
            refute_transactable_in_mixed_result(@adelaide)
          end

          should 'return only super location with half word' do
            get :index, loc: 'adelaide', query: 'loca', v: 'mixed'
            assert_transactable_in_mixed_result(@adelaide_super)
            refute_transactable_in_mixed_result(@adelaide)
          end

          should 'return both locations' do
            get :index, loc: 'adelaide', v: 'mixed'
            assert_transactable_in_mixed_result(@adelaide)
            assert_transactable_in_mixed_result(@adelaide_super)
          end

          should 'return one location by query only' do
            get :index, query: 'super', v: 'mixed'
            assert_transactable_in_mixed_result(@adelaide_super)
            refute_transactable_in_mixed_result(@adelaide)
          end
        end

        context 'on list results page' do
          should 'return only super location' do
            get :index, loc: 'adelaide', query: 'super', v: 'list'
            assert_location_in_mixed_result(@adelaide_super)
            refute_location_in_mixed_result(@adelaide)
          end

          should 'return only super location with half word' do
            get :index, loc: 'adelaide', query: 'loca', v: 'list'
            assert_location_in_mixed_result(@adelaide_super)
            refute_location_in_mixed_result(@adelaide)
          end

          should 'return both locations' do
            get :index, loc: 'adelaide', v: 'list'
            assert_location_in_mixed_result(@adelaide)
            assert_location_in_mixed_result(@adelaide_super)
          end

          should 'return one location by query only' do
            get :index, query: 'super', v: 'list'
            assert_location_in_mixed_result(@adelaide_super)
            refute_location_in_mixed_result(@adelaide)
          end
        end
      end
    end
  end

  context 'for mixed individual settings' do
    setup do
      TransactableType.first.update_attributes(default_search_view: 'listing_mixed')
      3.times { FactoryGirl.create(:listing_in_adelaide) }
      Transactable.searchable.import
      Transactable.__elasticsearch__.refresh_index!
    end

    should 'properly render all liquid views' do
      get :index
      assert_select 'article.location', count: 3
    end
  end

  context 'community' do
    setup do
      PlatformContext.current.instance.stubs(:is_community?).returns(true)
    end

    should 'fallback to "projects" when param is unknown' do
      get :index, search_type: 'something'
      assert_equal assigns(:search_type), 'projects'
    end

    should 'prepare view variables when param is known' do
      get :index, search_type: 'people'
      assert_equal assigns(:search_type), 'people'
    end

    should 'fallback to "projects" when no param' do
      get :index
      assert_equal assigns(:search_type), 'projects'
    end
  end

  protected

  def assert_nothing_found
    assert_select 'h1', 1, 'No results found'
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

  def assert_location_in_mixed_result(location)
    assert_select 'article[data-id=?]', location.id, count: 1
  end

  def assert_transactable_in_mixed_result(transactable)
    assert_select 'div.listing[data-id=?]', transactable.id, count: 1
  end

  def refute_transactable_in_mixed_result(transactable)
    assert_select 'div.listing[data-id=?]', transactable.id, count: 0
  end

  def refute_location_in_mixed_result(location)
    assert_select 'article[data-id=?]', location.id, count: 0
  end
end
