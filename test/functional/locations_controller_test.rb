require 'test_helper'

class LocationsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id)
    @location = FactoryGirl.create(:location_in_auckland) 
    @company.locations << @location
    stub_mixpanel
  end

  test "should return redirect status for show action if no listings" do
    get :show, :id => @location.id
    assert_response :redirect
  end

  should 'track location view' do
    @listing = FactoryGirl.create(:listing)
    @location.listings << @listing
    @location.save!
    @tracker.expects(:viewed_a_location).with do |location|
      location == assigns(:location)
    end
    get :show, id: @location.id, listing_id: @listing
    assert_response :success
  end

end

