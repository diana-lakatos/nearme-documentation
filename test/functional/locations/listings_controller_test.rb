require 'test_helper'

class Locations::ListingsControllerTest < ActionController::TestCase

  setup do
    @listing = FactoryGirl.create(:listing)
    @location = @listing.location
    stub_mixpanel
  end

  should 'show track viewed_a_location event' do
    @tracker.expects(:viewed_a_location).with do |location|
      location == assigns(:location)
    end
    get :show, location_id: @location.id, id: @listing
    assert_response :success
  end

  context 'edit links' do
    setup do
      @edit_listing_url = login_as_admin_user_path(@location.creator, :return_to => edit_manage_listing_path(@listing))
      @edit_location_url = login_as_admin_user_path(@location.creator, :return_to => edit_manage_location_path(@location))
    end

    should 'be visible for admins' do
      user = FactoryGirl.create(:user, admin: true).decorate
      Locations::ListingsController.any_instance.stubs(:current_user).returns(user)
      get :show, location_id: @location.id, id: @listing
      assert_select 'a[href=?]', @edit_listing_url, count: 1
      assert_select 'a[href=?]', @edit_location_url, count: 1
    end

    should 'be hidden for customers' do
      user = FactoryGirl.create(:user).decorate
      Locations::ListingsController.any_instance.stubs(:current_user).returns(user)
      get :show, location_id: @location.id, id: @listing
      assert_select 'a[href=?]', @edit_listing_url, count: 0
      assert_select 'a[href=?]', @edit_location_url, count: 0
    end

    should 'be hidden for anonymous users' do
      Locations::ListingsController.any_instance.stubs(:current_user).returns(nil)
      get :show, location_id: @location.id, id: @listing
      assert_select 'a[href=?]', @edit_listing_url, count: 0
      assert_select 'a[href=?]', @edit_location_url, count: 0
    end
  end
end

