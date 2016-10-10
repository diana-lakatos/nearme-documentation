require 'test_helper'

class ReservationChargeTrackerJobTest < ActiveSupport::TestCase
  setup do
    stub_active_merchant_interaction
    @transactable = FactoryGirl.create(:transactable, :with_time_based_booking)
    @transactable.action_type.pricing_for('1_day').price = 89.39
    @reservation = FactoryGirl.create(:unconfirmed_reservation, transactable: @transactable)
    @reservation.charge_and_confirm!
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
