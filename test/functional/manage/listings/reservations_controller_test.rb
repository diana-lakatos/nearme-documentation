require 'test_helper'

class Manage::Listings::ReservationsControllerTest < ActionController::TestCase

  setup do
    @reservation = FactoryGirl.create(:reservation_with_credit_card)
    stub_request(:get, /.*api\.mixpanel\.com.*/)
    @user = @reservation.listing.creator
    sign_in @user
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

  context 'PUT #reject' do
    should 'set rejection reason' do
      ReservationIssueLogger.expects(:rejected_with_reason).with(@reservation, @user)
      put :reject, { listing_id: @reservation.listing.id, id: @reservation.id, reservation: { rejection_reason: 'Dont like him' } }
      assert_equal @reservation.reload.rejection_reason, 'Dont like him'
    end
  end

end

