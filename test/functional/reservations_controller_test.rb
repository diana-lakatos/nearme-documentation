require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @reservation = FactoryGirl.create(:reservation_with_credit_card)
    stub_request(:get, /.*api\.mixpanel\.com.*/)
    sign_in @reservation.owner
  end

  should "redirect a host to the My Bookings page when they cancel a booking" do
    post :user_cancel, { listing_id: @reservation.listing.id, id: @reservation.id }
    assert_redirected_to bookings_dashboard_path
  end

end

