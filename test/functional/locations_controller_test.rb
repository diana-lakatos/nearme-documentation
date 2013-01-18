require 'test_helper'

class LocationsControllerTest < ActionController::TestCase

include Devise::TestHelpers

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user   
    @company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id)
    @location = FactoryGirl.create(:location_in_auckland)
    @company.locations << @location
  end

  ##
  # Email/Password Authentication

  test "should return success status for show action if no listings" do
    get :show, :id => @location.id
    assert_response :success
  end

end
