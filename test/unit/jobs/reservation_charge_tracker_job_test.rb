require 'test_helper'

class ReservationChargeTrackerJobTest < ActiveSupport::TestCase

  setup do
    stub_mixpanel
    Billing::Gateway::Processor::Incoming::Stripe.any_instance.expects(:charge)
    @listing = FactoryGirl.create(:transactable, :daily_price => 89.39)
    @listing.instance.instance_payment_gateways << FactoryGirl.create(:stripe_instance_payment_gateway)

    @reservation = FactoryGirl.create(:reservation_with_credit_card, :listing => @listing)
  end

  should 'perform tracking of confirmed reservation' do
    @reservation.confirm!
    Analytics::EventTracker.any_instance.expects(:track_charge).with(@reservation)
    ReservationChargeTrackerJob.perform(@reservation.id)
  end

  context 'cancelled' do
    setup do
      @reservation.confirm!
    end

    should 'do not perform tracking of cancelled reservation by host' do
      @reservation.host_cancel!
      Analytics::EventTracker.any_instance.expects(:track_charge).never
      ReservationChargeTrackerJob.perform(@reservation.id)
    end

    should 'do not perform tracking of cancelled reservation by user' do
      @reservation.user_cancel!
      Analytics::EventTracker.any_instance.expects(:track_charge).never
      ReservationChargeTrackerJob.perform(@reservation.id)
    end

  end
end
