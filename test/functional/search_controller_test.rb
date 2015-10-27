require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  setup do
    stub_request(:get, /.*maps\.googleapis\.com.*/).to_return(status: 404, body: {}.to_json, headers: {})
    stub_mixpanel
  end

  context 'for anything when no TransactableType exists' do
    setup do
      TransactableType.destroy_all
    end

    should 'redirect to homepage' do
      get :index, loc: "Anywhere"
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
        should 'find nothing for empty query' do
          get :index, loc: ''
          assert_nothing_found
        end

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
        context 'with industry filter' do
          should 'filter only filtered locations' do
            filtered_industry = FactoryGirl.create(:industry)
            another_industry = FactoryGirl.create(:industry)
            filtered_auckland = FactoryGirl.create(:company, industries: [filtered_industry], locations: [FactoryGirl.create(:location_in_auckland)]).locations.first
            another_auckland = FactoryGirl.create(:company, industries: [another_industry], locations: [FactoryGirl.create(:location_in_auckland)]).locations.first
            draft_auckland = FactoryGirl.create(:company, industries: [filtered_industry], locations: [FactoryGirl.create(:location_in_auckland)]).locations.first.tap do |location|
              location.listings.update_all(draft: Time.zone.now)
            end
            disabled_auckland = FactoryGirl.create(:company, industries: [filtered_industry], locations: [FactoryGirl.create(:location_in_auckland)]).locations.first.tap do |location|
              location.listings.update_all(enabled: false)
            end

            get :index, { loc: 'Auckland', industries_ids: [filtered_industry.id], v: 'list' }

            assert_location_in_result(filtered_auckland)
            refute_location_in_result(another_auckland)
            refute_location_in_result(draft_auckland)
            refute_location_in_result(disabled_auckland)
          end
        end

        context 'with location type filter' do
          should 'filter only filtered locations' do
            filtered_location_type = FactoryGirl.create(:location_type)
            another_location_type = FactoryGirl.create(:location_type)
            filtered_auckland = FactoryGirl.create(:location_in_auckland, location_type: filtered_location_type)
            another_auckland = FactoryGirl.create(:location_in_auckland, location_type: another_location_type)

            get :index, { loc: 'Auckland', lntype: filtered_location_type.name.downcase, v: 'mixed' }

            assert_location_in_result(filtered_auckland)
            refute_location_in_result(another_auckland)
          end
        end

        context 'with listing type filter' do
          should 'filter only filtered locations' do
            filtered_listing_type = "Desk"
            another_listing_type = "Meeting Room"
            service_type = ServiceType.first || FactoryGirl.create(:transactable_type_listing)
            filtered_auckland = FactoryGirl.create(:listing_in_auckland, transactable_type: service_type, properties: { listing_type: filtered_listing_type }).location
            another_auckland = FactoryGirl.create(:listing_in_auckland, transactable_type: service_type, properties: { listing_type: another_listing_type }).location

            get :index, { loc: 'Auckland', lg_custom_attributes: { 'listing_type' => [filtered_listing_type] }, v: 'mixed' }

            assert_location_in_mixed_result(filtered_auckland)
            refute_location_in_mixed_result(another_auckland)
          end
        end

        context 'with attribute value filter' do
          should 'filter only filtered locations' do
            FactoryGirl.create(:custom_attribute, target: TransactableType.first, attribute_type: 'string', name: 'filterable_attribute', searchable: true, valid_values: ['Righthanded', 'Lefthanded'])
            listing = FactoryGirl.create(:listing_in_cleveland, photos_count: 1, properties: { filterable_attribute: 'Lefthanded' })
            filtered_auckland = listing.location

            another_auckland = FactoryGirl.create(:listing_in_cleveland, properties: { filterable_attribute: ['Righthanded'] }).location
            get :index, { loc: 'Cleveland', lg_custom_attributes: { filterable_attribute: ['Lefthanded'] }, v: 'mixed' }

            assert_location_in_mixed_result(filtered_auckland)
            refute_location_in_mixed_result(another_auckland)
          end
        end

        context 'with category filter' do
          setup do
            @filtered_category = FactoryGirl.create(:category, name: "Desk")
            @filtered_category_child = FactoryGirl.create(:category, name: "Standing Desk", parent: @filtered_category)
            @another_category = FactoryGirl.create(:category, name: "Meeting Room")
            @filtered_auckland_1 = FactoryGirl.create(:listing_in_auckland, category_ids: ["[#{@filtered_category.id}, #{@another_category.id}]"]).location
            @filtered_auckland_2 = FactoryGirl.create(:listing_in_auckland, category_ids: ["[#{@filtered_category_child.id}]"]).location
            @another_auckland = FactoryGirl.create(:listing_in_auckland, category_ids: ["[#{@another_category.id}]"]).location
          end

          should 'filter only filtered locations when "OR" search mode' do
            PlatformContext.current.instance.update_attribute(:category_search_type, 'OR')
            get :index, { loc: 'Auckland', category_ids: @filtered_category.id, v: 'mixed', buyable: false}
            assert_location_in_mixed_result(@filtered_auckland_1)
            assert_location_in_mixed_result(@filtered_auckland_2)
            refute_location_in_mixed_result(@another_auckland)
          end

          should 'filter only filtered locations when "AND" search mode' do
            PlatformContext.current.instance.update_attribute(:category_search_type, 'AND')
            get :index, { loc: 'Auckland', category_ids: "#{@filtered_category.id},#{@another_category.id}", v: 'mixed', buyable: false}
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

                  FactoryGirl.create(:past_reservation, listing: FactoryGirl.create(:transactable, location: @adelaide), user: @friend, state: 'confirmed')
                end

                should 'are shown for logged user' do
                  sign_in(@me)
                  @me.stubs(:unread_messages_count).returns(0)

                  get :index, loc: 'Adelaide', v: 'list'

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
           @adelaide_super.description = "super location"
           @adelaide_super.save
           PlatformContext.current.instance.update_attribute(:searcher_type, "fulltext_geo")
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


      should "not track search for empty query" do
        @tracker.expects(:conducted_a_search).never
        get :index, loc: nil
      end

      should 'track search for first page' do
        @tracker.expects(:conducted_a_search).once
        get :index, loc: 'adelaide', page: 1
      end

      should 'not track search for second page' do
        @tracker.expects(:conducted_a_search).never
        get :index, loc: 'adelaide', page: 2
      end

      should 'log filters in mixpanel along with other arguments for list result type' do
        @listing_type = "Meeting Room"
        @location_type = FactoryGirl.create(:location_type)
        @industry = FactoryGirl.create(:industry)
        expected_custom_options = {
          search_query: 'adelaide',
          result_view: 'list',
          result_count: 0,
          custom_attributes: { 'listing_type' => [@listing_type] },
          location_type_filter: [@location_type.name],
          industry_filter: [@industry.name],
        }
        @tracker.expects(:conducted_a_search).with do |search, custom_options|
          expected_custom_options == custom_options
        end
        get :index, { loc: 'adelaide', lg_custom_attributes: { listing_type: [@listing_type] }, location_types_ids: [@location_type.id], industries_ids: [@industry.id], v: 'list' }
      end

      should 'log filters in mixpanel along with other arguments for mixed result type' do
        @listing_type = "Desk"
        @location_type = FactoryGirl.create(:location_type)
        expected_custom_options = {
          search_query: 'adelaide',
          result_view: 'mixed',
          result_count: 0,
          custom_attributes: { 'listing_type' => [@listing_type] },
          location_type_filter: [@location_type.name],
          listing_pricing_filter: ['daily'],
        }
        @tracker.expects(:conducted_a_search).with do |search, custom_options|
          expected_custom_options == custom_options
        end
        get :index, { loc: 'adelaide', lg_custom_attributes: { listing_type: [@listing_type] }, lntype: @location_type.name.downcase, lgpricing: 'daily', v: 'mixed' }
      end

      should 'track search if ignore_search flag is set to 0' do
        @tracker.expects(:conducted_a_search).once
        get :index, loc: 'adelaide', ignore_search_event: "0"
      end

      should 'not track search if ignore_search flag is set to 1' do
        @tracker.expects(:conducted_a_search).never
        get :index, loc: 'adelaide', ignore_search_event: "1"
      end

      should 'not track second search for the same query if filters have not been changed' do
        @tracker.expects(:conducted_a_search).once
        get :index, loc: 'adelaide'
        get :index, loc: 'adelaide'
      end

      context 'modified filters' do

        setup do
          @tracker.expects(:conducted_a_search).twice
          get :index, loc: 'adelaide'
          @controller.instance_variable_set(:@search, nil)
        end

        should 'track search if listing filter has been modified' do
          get :index, loc: 'adelaide', lg_custom_attributes: { listing_type: ["Some Filter"] }
        end

        should 'track search if location filter has been modified' do
          get :index, loc: 'adelaide', lntype: FactoryGirl.create(:location_type).name.downcase
        end

        should 'track search if industry filter has been modified' do
          get :index, loc: 'adelaide', industries_ids: [FactoryGirl.create(:industry).id], v: 'list'
        end

        should 'track search if listing pricing filter has been modified' do
          get :index, loc: 'adelaide', lgpricing: 'daily'
        end

      end

      should 'not track second search for the different query' do
        @tracker.expects(:conducted_a_search).twice
        get :index, loc: 'adelaide'
        get :index, loc: 'auckland'
      end

    end
  end

  context 'for transactable type buy/sell' do
    setup do
      FactoryGirl.create(:product_type)
    end

    context 'search integration' do
      setup do
        Spree::Product.destroy_all
      end

      context 'for disabled listing' do
        should 'exclude disabled listing' do
          FactoryGirl.create(:product, approved: false, name: 'product')

          get :index, query: 'product', v: 'products', buyable: 'true'
          assert_no_products_found
        end
      end

      context 'for invalid place' do
        should 'find nothing for empty query' do
          get :index, query: '', v: 'products', buyable: 'true'
          assert_no_products_found
        end

        should 'find nothing for invalid query' do
          get :index, query: 'bung', v: 'products', buyable: 'true'
          assert_no_products_found
        end
      end

      context 'for existing products' do
        context 'with category filter' do
          setup do
            parent = FactoryGirl.create(:category, name: 'Categories')
            @category = FactoryGirl.create(:category, name: 'category_1', parent: parent)
            @another_category = FactoryGirl.create(:category, parent: parent)
            @filtered_product = FactoryGirl.create(:product, categories: [@category])
            @another_product = FactoryGirl.create(:product, categories: [@another_category])
          end

          should 'filter only filtered products' do
            get :index, { category_ids: @category.id, v: 'products', buyable: 'true' }

            assert_product_in_result(@filtered_product)
            refute_product_in_result(@another_product)
          end

          should 'query only filtered products' do
            another_product2 = FactoryGirl.create(:product, name: 'product three', categories: [@another_category])

            get :index, { category_ids: @category.id, v: 'products', buyable: 'true', query: 'product' }

            assert_product_in_result(@filtered_product)
            refute_products_in_result([@another_product, another_product2])
          end
        end

        context 'without filter' do
          setup do
            @product_type = FactoryGirl.create(:product_type, :with_custom_attribute)
            @product1 = FactoryGirl.create(:product, name: 'product_one', product_type: @product_type)
            @product2 = FactoryGirl.create(:product, name: 'product_two', product_type: @product_type)
            @product3 = FactoryGirl.create(:product, name: 'product three', product_type: @product_type)
            @product3.extra_properties['manufacturer'] = "Bosh"
            @product3.save
          end

          should 'not show products that belong to different product type' do
            get :index, query: 'product_one', v: 'products', buyable: 'true', transactable_type_id: FactoryGirl.create(:product_type).id
            refute_products_in_result([@product1, @product2, @product3])
          end

          should 'show only valid products' do
            get :index, query: 'product_one', v: 'products', buyable: 'true', transactable_type_id: @product_type.id
            assert_product_in_result(@product1)
            refute_products_in_result([@product2, @product3])
          end

          should 'show only valid products like' do
            get :index, query: 'product one', v: 'products', buyable: 'true', transactable_type_id: @product_type.id
            assert_products_in_result([@product1, @product2, @product3])
          end

          should 'show only valid products from extra_properties' do
            get :index, query: 'product_one bosh', v: 'products', buyable: 'true', transactable_type_id: @product_type.id
            assert_products_in_result([@product1, @product3])
            refute_product_in_result(@product2)
          end
        end
      end
    end

    context 'conduct search' do

      should "not track search for empty query" do
        @tracker.expects(:conducted_a_search).never
        get :index, query: nil, v: 'products', buyable: 'true'
      end

      should 'track search for first page' do
        @tracker.expects(:conducted_a_search).once
        get :index, query: 'product_1', page: 1, v: 'products', buyable: 'true'
      end

      should 'not track search for second page' do
        @tracker.expects(:conducted_a_search).never
        get :index, query: 'product_1', page: 2, v: 'products', buyable: 'true'
      end

      should 'not track second search for the different query' do
        @tracker.expects(:conducted_a_search).twice
        get :index, query: 'product_1', v: 'products', buyable: 'true'
        get :index, query: 'product_2', v: 'products', buyable: 'true'
      end

      should 'track search if ignore_search flag is set to 0' do
        @tracker.expects(:conducted_a_search).once
        get :index, query: 'product_1', ignore_search_event: "0", v: 'products', buyable: 'true'
      end

      should 'not track search if ignore_search flag is set to 1' do
        @tracker.expects(:conducted_a_search).never
        get :index, query: 'product_1', ignore_search_event: "1", v: 'products', buyable: 'true'
      end

      should 'not track second search for the same query if filters have not been changed' do
        @tracker.expects(:conducted_a_search).once
        get :index, query: 'product_1', v: 'products', buyable: 'true'
        get :index, query: 'product_1', v: 'products', buyable: 'true'
      end

      should 'log filters in mixpanel along with other arguments for products result type' do
        expected_custom_options = {
          search_query: 'product_1',
          result_view: 'products',
          result_count: 0,
          custom_attributes: { 'attribute_filter' => ['Lefthanded'] }
        }
        @tracker.expects(:conducted_a_search).with do |search, custom_options|
          expected_custom_options == custom_options
        end
        get :index, { query: 'product_1', lg_custom_attributes: { attribute_filter: ['Lefthanded'] }, v: 'products', buyable: 'true' }
      end
    end
  end

  protected

  def assert_nothing_found
    assert_select 'h1', 1, 'No results found'
  end

  def assert_no_products_found
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

  def assert_products_in_result(products)
    products.each do |product|
      assert_product_in_result(product)
    end
  end

  def refute_products_in_result(products)
    products.each do |product|
      refute_product_in_result(product)
    end
  end

  def assert_product_in_result(product)
    assert_select '.result-item[data-product-id=?]', product.id, count: 1
  end

  def refute_product_in_result(product)
    assert_select '.result-item[data-product-id=?]', product.id, count: 0
  end


end

