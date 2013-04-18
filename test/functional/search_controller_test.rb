require 'test_helper'

class SearchControllerTest < ActionController::TestCase

include Devise::TestHelpers

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id)
    @location = FactoryGirl.create(:location_in_auckland)
    @company.locations << @location
    stub_request(:get, /.*api\.mixpanel\.com.*/)
  end

  # This fails because the search method is triggered twice every search for some reason
  test "should track search view" do
    Track::Search.expects(:conducted_a_search)
    get :index
  end

end
