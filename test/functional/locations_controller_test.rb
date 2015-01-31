require 'test_helper'

class LocationsControllerTest < ActionController::TestCase

  setup do
    @location = FactoryGirl.create(:location_in_auckland)
    @listing = FactoryGirl.create(:transactable, :location => @location)
    @second_listing = FactoryGirl.create(:transactable, :location => @location)
    stub_mixpanel
  end

  context '#show' do

    should 'track impression' do
      assert_difference 'Impression.count' do
        get :show, id: @location.id
      end
    end

    context 'without listing' do

      should "work" do
        get :show, id: @location.id
        assert_response :success
      end

      should 'track viewed_a_location event' do
        @tracker.expects(:viewed_a_location).with do |location|
          location == assigns(:location)
        end
        get :show, id: @location.id
      end

    end

    context 'with listing' do

      should 'track viewed_a_location event' do
        @tracker.expects(:viewed_a_location).with do |location|
          location == assigns(:location)
        end
        get :show, id: @location.id, listing_id: @listing
      end

      should 'render show action if show page disabled' do
        get :show, id: @location.id, listing_id: @listing
        assert_response :success
      end

      should 'redirect to individual listing page if enabled' do
        @listing.transactable_type.update_attribute(:show_page_enabled, true)
        get :show, id: @location.id, listing_id: @listing
        assert_response :redirect
        assert_redirected_to location_listing_path(@location, @listing)
      end

      should 'show warning if listing is inactive but there is at least one active listing' do
        @listing.update_attributes(draft: Time.now)
        get :show, id: @location.id, listing_id: @listing
        assert_response :redirect
        assert_redirected_to location_path(@location)
        assert flash[:warning].include?('This listing is inactive'), "Expected #{flash[:warning]} to include 'This listing is inactive'"
      end

      context 'listing is disabled' do
        setup do
          @listing.update_attributes(enabled: false)
        end

        should 'show warning if user cannot manage listing and there is at least one active listing' do
          get :show, id: @location.id, listing_id: @listing
          assert_response :redirect
          assert_redirected_to location_path(@location)
          assert flash[:warning].include?('This listing has been temporarily disabled by the owner'), "Expected #{flash[:warning]} to include 'This listing is inactive'"
        end

        should 'show warning if random user is logged in' do
          sign_in FactoryGirl.create(:user)
          get :show, id: @location.id, listing_id: @listing
          assert_response :redirect
          assert_redirected_to location_path(@location)
          assert flash[:warning].include?('This listing has been temporarily disabled by the owner'), "Expected #{flash[:warning]} to include 'This listing is inactive'"
        end

        should 'show warning but not redirect if user can manage listing' do
          sign_in @location.creator
          get :show, id: @location.id, listing_id: @listing
          assert_response :success
          assert_not_nil flash[:warning]
        end
      end

      should 'redirect to search if listing is inactive and there are no other listings' do
        @second_listing.destroy
        @listing.update_attributes(draft: Time.now, enabled: false)
        get :show, id: @location.id, listing_id: @listing
        assert_redirected_to search_path(loc: @listing.address)
      end
    end

    context 'edit links' do

      setup do
        @edit_location_url = login_as_admin_user_path(@location.creator, :return_to => edit_dashboard_company_location_path(@location))
      end

      context 'user is logged in' do
        setup do
          @user = FactoryGirl.create(:user).decorate
          sign_in @user
        end

        should 'be visible for admins' do
          @user.update_attribute(:admin, true)
          get :show, id: @location.id
          assert_select 'a[href=?]', @edit_location_url, count: 1
        end

        should 'be hidden for customers' do
          get :show, id: @location.id
          assert_select 'a[href=?]', @edit_location_url, count: 0
        end
      end

      should 'be hidden for anonymous users' do
        get :show, id: @location.id
        assert_select 'a[href=?]', @edit_location_url, count: 0
      end
    end

  end
end
