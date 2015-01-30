require 'test_helper'

class RecurringBookingTest < ActiveSupport::TestCase

  should belong_to(:listing)
  should belong_to(:owner)
  should have_many(:reservations)

  setup do
    stub_mixpanel
  end

  context 'scopes' do

    setup do
      @recurring_booking = FactoryGirl.create(:recurring_booking)
    end

    context 'upcoming' do

      should 'be upcoming if both start and end dates are in future' do
        assert_equal 1, RecurringBooking.upcoming.count
      end

      should 'be upcoming if start date is in past ' do
        @recurring_booking.update_attribute(:start_on, Date.yesterday)
        assert_equal 1, RecurringBooking.upcoming.count
      end

      should 'not be upcoming if end date is in past ' do
        @recurring_booking.update_attribute(:end_on, Date.yesterday)
        assert_equal 0, RecurringBooking.upcoming.count
      end

    end

  end

  context 'changing state' do

    setup do
      @recurring_booking = FactoryGirl.create(:recurring_booking)
    end

    context 'confirm' do

      should "do not change state of previously rejected reservations" do
        @rejected_reservation = @recurring_booking.reservations.last
        @rejected_reservation.reject!
        @recurring_booking.confirm!
        assert_equal 5, @recurring_booking.reservations.confirmed.count
        assert_equal 1, @recurring_booking.reservations.rejected.count
      end

    end

    should "be able to cancel all unconfirmed reservations by guest" do
      Reservation.any_instance.expects(:attempt_payment_refund).at_least(@recurring_booking.reservations.count).at_most(@recurring_booking.reservations.count)
      @recurring_booking.user_cancel!
      assert @recurring_booking.reload.reservations.all?(&:cancelled_by_guest?)
      refute @recurring_booking.reload.reservations.any?(&:cancelled_by_host?)
    end

    should "be able to cancel all confirmed reservations by guest" do
      @recurring_booking.confirm!
      Reservation.any_instance.expects(:attempt_payment_refund).at_least(@recurring_booking.reservations.count).at_most(@recurring_booking.reservations.count)
      @recurring_booking.user_cancel!
      assert @recurring_booking.reload.reservations.all?(&:cancelled_by_guest?)
      refute @recurring_booking.reload.reservations.any?(&:cancelled_by_host?)
    end

    should "be able to cancel all reservations by host" do
      @recurring_booking.confirm!
      Reservation.any_instance.expects(:attempt_payment_refund).at_least(@recurring_booking.reservations.count).at_most(@recurring_booking.reservations.count)
      @recurring_booking.host_cancel!
      assert @recurring_booking.reload.reservations.all?(&:cancelled_by_host?)
      refute @recurring_booking.reload.reservations.any?(&:cancelled_by_guest?)
    end

    should "be able to reject all reservations except of confirmed" do
      @confirmed_reservation = @recurring_booking.reservations.last
      @confirmed_reservation.confirm!
      @recurring_booking.reject!
      assert_equal 5, @recurring_booking.reservations.rejected.count
      assert_equal 1, @recurring_booking.reservations.confirmed.count
    end

    should "be able to expire all reservations except of confirmed and send email" do
      @confirmed_reservation = @recurring_booking.reservations.last
      @confirmed_reservation.confirm!


      WorkflowStepJob.expects(:perform).with(WorkflowStep::RecurringBookingWorkflow::Expired, @recurring_booking.id)
      @recurring_booking.perform_expiry!
      assert_equal 5, @recurring_booking.reservations.expired.count
      assert_equal 1, @recurring_booking.reservations.confirmed.count
    end

  end

end

