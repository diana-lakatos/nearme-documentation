require 'test_helper'

class Manage::Listings::ReservationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @reservation = FactoryGirl.create(:reservation_with_credit_card)
    stub_request(:get, /.*api\.mixpanel\.com.*/)
    sign_in @reservation.listing.creator
  end

  should "redirect a host to the Manage Guests page when they confirm a booking" do
    post :confirm, { listing_id: @reservation.listing.id, id: @reservation.id }
    assert_redirected_to manage_guests_dashboard_path
  end

  should "redirect a host to the Manage Guests page when they reject a booking" do
    post :reject, { listing_id: @reservation.listing.id, id: @reservation.id }
    assert_redirected_to manage_guests_dashboard_path
  end

  should "redirect a host to the Manage Guests page when they cancel a booking" do
    post :host_cancel, { listing_id: @reservation.listing.id, id: @reservation.id }
    assert_redirected_to manage_guests_dashboard_path
  end

end

