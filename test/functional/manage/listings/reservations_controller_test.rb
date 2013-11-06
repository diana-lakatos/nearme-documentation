require 'test_helper'

class Manage::Listings::ReservationsControllerTest < ActionController::TestCase

  setup do
    @reservation = FactoryGirl.create(:reservation_with_credit_card)
    @user = @reservation.listing.creator
    sign_in @user
    stub_mixpanel
    User::BillingGateway.any_instance.stubs(:charge)
  end

  should "track and redirect a host to the Manage Guests page when they confirm a booking" do
    ReservationMailer.expects(:notify_guest_of_confirmation).returns(stub(deliver: true)).once
    ReservationMailer.expects(:notify_host_of_confirmation).returns(stub(deliver: true)).once

    @tracker.expects(:confirmed_a_booking).with do |reservation|
      reservation == assigns(:reservation)
    end
    @tracker.expects(:updated_profile_information).with do |user|
      user == assigns(:reservation).owner
    end
    @tracker.expects(:updated_profile_information).with do |user|
      user == assigns(:reservation).host
    end
    post :confirm, { listing_id: @reservation.listing.id, id: @reservation.id }
    assert_redirected_to manage_guests_dashboard_path
  end

  should "track and redirect a host to the Manage Guests page when they reject a booking" do
    ReservationMailer.expects(:notify_guest_of_rejection).returns(stub(deliver: true)).once

    @tracker.expects(:rejected_a_booking).with do |reservation|
      reservation == assigns(:reservation)
    end
    @tracker.expects(:updated_profile_information).with do |user|
      user == assigns(:reservation).owner
    end
    @tracker.expects(:updated_profile_information).with do |user|
      user == assigns(:reservation).host
    end
    post :reject, { listing_id: @reservation.listing.id, id: @reservation.id }
    assert_redirected_to manage_guests_dashboard_path
  end

  should "track and redirect a host to the Manage Guests page when they cancel a booking" do
    ReservationMailer.expects(:notify_guest_of_cancellation_by_host).returns(stub(deliver: true)).once

    @reservation.confirm # Must be confirmed before can be cancelled
    @tracker.expects(:cancelled_a_booking).with do |reservation, custom_options|
      reservation == assigns(:reservation) && custom_options == { actor: 'host' }
    end
    @tracker.expects(:updated_profile_information).with do |user|
      user == assigns(:reservation).owner
    end
    @tracker.expects(:updated_profile_information).with do |user|
      user == assigns(:reservation).host
    end
    post :host_cancel, { listing_id: @reservation.listing.id, id: @reservation.id }
    assert_redirected_to manage_guests_dashboard_path
  end

  context 'PUT #reject' do
    should 'set rejection reason' do
      ReservationMailer.expects(:notify_guest_of_rejection).returns(stub(deliver: true)).once
      ReservationIssueLogger.expects(:rejected_with_reason).with(@reservation, @user)
      put :reject, { listing_id: @reservation.listing.id, id: @reservation.id, reservation: { rejection_reason: 'Dont like him' } }
      assert_equal @reservation.reload.rejection_reason, 'Dont like him'
    end
  end

end

