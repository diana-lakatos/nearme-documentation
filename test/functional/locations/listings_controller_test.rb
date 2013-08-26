require 'test_helper'

class Locations::ListingsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id)
    @location = FactoryGirl.create(:location_in_auckland, :company => @company) 
    @listing = FactoryGirl.create(:listing, :location => @location)
    stub_mixpanel
  end

  should 'redirect lgacy urls to correct paths' do
    @tracker.expects(:viewed_a_location).with do |location|
      location == assigns(:location)
    end
    get :show, location_id: @location.id, id: @listing
    assert_response :success
  end

end

