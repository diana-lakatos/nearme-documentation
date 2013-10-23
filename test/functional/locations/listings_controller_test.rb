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
    should 'be visible for location admins' do
      user = FactoryGirl.create(:user, admin: true, companies: [@location.company])
      Locations::ListingsController.any_instance.stubs(:current_user).returns(user)
      get :show, location_id: @location.id, id: @listing
      assert_select 'a[href=?]', edit_manage_listing_path(@listing), count: 1
      assert_select 'a[href=?]', edit_manage_location_path(@location), count: 1
    end

    should 'be hidden for customers' do
      user = FactoryGirl.create(:user)
      Locations::ListingsController.any_instance.stubs(:current_user).returns(user)
      get :show, location_id: @location.id, id: @listing
      assert_select 'a[href=?]', edit_manage_listing_path(@listing), count: 0
      assert_select 'a[href=?]', edit_manage_location_path(@location), count: 0
    end

    should 'be hidden for anonymous users' do
      Locations::ListingsController.any_instance.stubs(:current_user).returns(nil)
      get :show, location_id: @location.id, id: @listing
      assert_select 'a[href=?]', edit_manage_listing_path(@listing), count: 0
      assert_select 'a[href=?]', edit_manage_location_path(@location), count: 0
    end
  end
end

