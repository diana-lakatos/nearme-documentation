require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id)
    @location = FactoryGirl.create(:location_in_auckland)
    @company.locations << @location
  end

  context 'GET bookings' do
    should 'redirect if no bookings' do
      get :bookings
      assert_redirected_to search_path
      assert_equal "You haven't made any bookings yet!", flash[:warning]
    end

    should 'render view if any bookings' do
      FactoryGirl.create(:reservation_with_valid_period, owner: @user)
      get :bookings
      assert_response :success
    end
  end

end

