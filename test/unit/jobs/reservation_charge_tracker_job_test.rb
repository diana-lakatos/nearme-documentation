require 'test_helper'

class ReservationChargeTrackerJobTest < ActiveSupport::TestCase

  setup do
    stub_active_merchant_interaction
    @listing = FactoryGirl.create(:transactable, :daily_price => 89.39)
    @reservation = FactoryGirl.create(:reservation_with_credit_card, :listing => @listing)
    @reservation.create_billing_authorization(token: "token", payment_gateway: FactoryGirl.create(:stripe_payment_gateway), payment_gateway_mode: "test")
    @reservation.confirm!
  end

  should 'perform tracking of confirmed reservation' do
    Rails.application.config.event_tracker.any_instance.expects(:track_charge).with(@reservation)
    ReservationChargeTrackerJob.perform(@reservation.id)
  end

  context 'cancelled' do
    should 'do not perform tracking of cancelled reservation by host' do
      @reservation.host_cancel!
      Rails.application.config.event_tracker.any_instance.expects(:track_charge).never
      ReservationChargeTrackerJob.perform(@reservation.id)
    end

    should 'do not perform tracking of cancelled reservation by user' do
      @reservation.user_cancel!
      Rails.application.config.event_tracker.any_instance.expects(:track_charge).never
      ReservationChargeTrackerJob.perform(@reservation.id)
    end

  end
end
