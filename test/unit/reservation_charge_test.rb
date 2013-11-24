require 'test_helper'

class ReservationChargeTest < ActiveSupport::TestCase

  setup do
    @reservation = FactoryGirl.create(:reservation_with_credit_card)
    stub_mixpanel
  end

  setup do
    @expectation = ReservationChargeTrackerJob.expects(:perform_later).with(@reservation.date.end_of_day, @reservation.id)
  end

  should 'track charge in mixpanel after successful creation' do
    User::BillingGateway.any_instance.stubs(:charge)
    @expectation.once
    @reservation.reservation_charges.create!(
      subtotal_amount: 105.24,
      service_fee_amount: 23.18
    )
  end

  should 'do not track charge in mixpanel if there is error processing credit card' do
    User::BillingGateway.any_instance.stubs(:charge).raises(User::BillingGateway::CardError)
    @expectation.never
    @reservation.reservation_charges.create!(
      subtotal_amount: 105.24,
      service_fee_amount: 23.18
    )
  end
end
