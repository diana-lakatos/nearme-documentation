require 'test_helper'

class Manage::Listings::ReservationsControllerTest < ActionController::TestCase

  setup do
    @reservation = FactoryGirl.create(:reservation_with_credit_card)
    @reservation.create_billing_authorization(token: "123", payment_gateway_class: "Billing::Gateway::Processor::Incoming::Stripe", payment_gateway_mode: "test")
    @user = @reservation.listing.creator
    sign_in @user
    stub_mixpanel
    stub_request(:post, "https://www.googleapis.com/urlshortener/v1/url")
    stub_billing_gateway(@reservation.instance)
    stub_active_merchant_interaction
  end

  should "track and redirect a host to the Manage Guests page when they confirm a booking" do
    ReservationMailer.expects(:notify_guest_of_confirmation).returns(stub(deliver: true)).once
    ReservationMailer.expects(:notify_host_of_confirmation).returns(stub(deliver: true)).once
    ReservationSmsNotifier.expects(:notify_guest_with_state_change).returns(stub(deliver: true)).once

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
    ReservationSmsNotifier.expects(:notify_guest_with_state_change).returns(stub(deliver: true)).once

    @tracker.expects(:rejected_a_booking).with do |reservation|
      reservation == assigns(:reservation)
    end
    @tracker.expects(:updated_profile_information).with do |user|
      user == assigns(:reservation).owner
    end
    @tracker.expects(:updated_profile_information).with do |user|
      user == assigns(:reservation).host
    end
    put :reject, { listing_id: @reservation.listing.id, id: @reservation.id }
    assert_redirected_to manage_guests_dashboard_path
  end

  should "track and redirect a host to the Manage Guests page when they cancel a booking" do
    ReservationMailer.expects(:notify_guest_of_cancellation_by_host).returns(stub(deliver: true)).once
    ReservationSmsNotifier.expects(:notify_guest_with_state_change).returns(stub(deliver: true)).once

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

  should "refund booking on cancel" do
    ActiveMerchant::Billing::Base.mode = :test
    response = gateway.authorize(@reservation.total_amount_cents, credit_card)
    @reservation.confirm
    
    sign_in @reservation.listing.creator
    User.any_instance.stubs(:accepts_sms_with_type?)

    setup_refund_for_reservation(@reservation)

    assert_difference 'Refund.count' do
      post :host_cancel, { listing_id: @reservation.listing.id, id: @reservation.id }
    end

    assert_redirected_to manage_guests_dashboard_path
    assert_equal 'refunded', @reservation.reload.payment_status
  end

  context 'PUT #reject' do
    should 'set rejection reason' do
      ReservationMailer.expects(:notify_guest_of_rejection).returns(stub(deliver: true)).once
      ReservationIssueLogger.expects(:rejected_with_reason).with(@reservation, @user)
      ReservationSmsNotifier.expects(:notify_guest_with_state_change).returns(stub(deliver: true)).once
      put :reject, { listing_id: @reservation.listing.id, id: @reservation.id, reservation: { rejection_reason: 'Dont like him' } }
      assert_equal @reservation.reload.rejection_reason, 'Dont like him'
    end
  end

  context 'versions' do

    should 'store new version after confirm' do
      # 2 because attempt charge is triggered, which if successful generates second version
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Reservation", "update").count', 2) do
        with_versioning do
          post :confirm, { listing_id: @reservation.listing.id, id: @reservation.id }
        end
      end
    end

    should 'store new version after reject' do
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Reservation", "update").count') do
        with_versioning do
          put :reject, { listing_id: @reservation.listing.id, id: @reservation.id, reservation: { rejection_reason: 'Dont like him' } }
        end
      end
    end

    should 'store new version after cancel' do
      @reservation.confirm
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Reservation", "update").count') do
        with_versioning do
          post :host_cancel, { listing_id: @reservation.listing.id, id: @reservation.id }
        end
      end
    end   

  end

  def credit_card
    ActiveMerchant::Billing::CreditCard.new(
      :number             => "4242424242424242",
      :month              => "12",
      :year               => "2020",
      :verification_value => "411"
    )
  end

  def gateway
    Billing::Gateway::Processor::Incoming::ProcessorFactory.create(@user, @user.instance, "USD")
  end

  def setup_refund_for_reservation(reservation)
    reservation.reservation_charges.last.charge_attempts.successful.create(amount: reservation.total_amount_cents)
    Billing::Gateway::Processor::Incoming::Stripe.any_instance.stubs(:refund_identification)
      .returns({id: "123"}.to_json)
    ActiveMerchant::Billing::StripeGateway.any_instance.stubs(:refund)
      .returns(ActiveMerchant::Billing::BogusGateway.new.refund(reservation.total_amount_cents, "123"))
  end
end

