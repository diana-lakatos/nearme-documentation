require 'test_helper'

class Reservation::CancellationPolicyTest < ActiveSupport::TestCase

  context '#cancelable' do

    setup do
      @reservation = stub(
        cancellation_policy_hours_for_cancellation: 24,
        date: Date.tomorrow,
        first_period: stub(start_minute: 540)
      )
      @cancellation_policy = Reservation::CancellationPolicy.new(@reservation)
    end

    should 'be cancellable if more than 24 hours remain to reservation' do
      Timecop.travel(Time.zone.now - 1.day) { assert @cancellation_policy.cancelable? }
    end

    should 'not be cancellable when 24 hours left to reservation' do
      Timecop.travel(Time.zone.now) { refute @cancellation_policy.cancelable? }
    end

  end

end
