require 'test_helper'

class LocationsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id)
    @location = FactoryGirl.create(:location_in_auckland, :company => @company) 
    @listing = FactoryGirl.create(:listing, :location => @location)
    @second_listing = FactoryGirl.create(:listing, :location => @location)
    stub_mixpanel
  end

  test "should return redirect status for show action if no listings" do
    get :show, :id => @location.id
    assert_response :redirect
  end

  should 'redirect legacy urls to current paths' do
    get :show, id: @location.id, listing_id: @second_listing
    assert_response :redirect
    assert_redirected_to location_listing_path(@location, @second_listing)
  end

  should 'redirect to first listing if none provided' do
    get :show, id: @location.id
    assert_response :redirect
    assert_redirected_to location_listing_path(@location, @listing)
  end

end

