require 'test_helper'

class Manage::Listings::ReservationsControllerTest < ActionController::TestCase

  setup do
    @reservation = FactoryGirl.create(:reservation_with_credit_card)
    stub_request(:get, /.*api\.mixpanel\.com.*/)
    sign_in @reservation.listing.creator
    @tracker = Analytics::EventTracker.any_instance
    User::BillingGateway.any_instance.stubs(:charge)
  end

  should "track and redirect a host to the Manage Guests page when they confirm a booking" do
    @tracker.expects(:confirmed_a_booking).with do |reservation|
      reservation == assigns(:reservation)
    end
    post :confirm, { listing_id: @reservation.listing.id, id: @reservation.id }
    assert_redirected_to manage_guests_dashboard_path
  end

  should "track and redirect a host to the Manage Guests page when they reject a booking" do
    @tracker.expects(:rejected_a_booking).with do |reservation|
      reservation == assigns(:reservation)
    end
    post :reject, { listing_id: @reservation.listing.id, id: @reservation.id }
    assert_redirected_to manage_guests_dashboard_path
  end

  should "track and redirect a host to the Manage Guests page when they cancel a booking" do
    @reservation.confirm # Must be confirmed before can be cancelled
    @tracker.expects(:cancelled_a_booking).with do |reservation, custom_options|
      reservation == assigns(:reservation) && custom_options == { actor: 'host' }
    end
    post :host_cancel, { listing_id: @reservation.listing.id, id: @reservation.id }
    assert_redirected_to manage_guests_dashboard_path
  end

end

