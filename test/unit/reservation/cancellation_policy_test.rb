require 'test_helper'

class Reservation::CancellationPolicyTest < ActiveSupport::TestCase

  context '#cancelable' do

    setup do
      @reservation = stub(
        cancellation_policy_hours_for_cancellation: 24,
        starts_at: Date.tomorrow.beginning_of_day.advance(hours: 9)
      )
    end

    should 'be cancellable if more than 24 hours remain to reservation' do
      travel_to(@reservation.starts_at - 25.hours) do
        @cancellation_policy = Reservation::CancellationPolicy.new(@reservation)
        assert @cancellation_policy.cancelable?
      end
    end

    should 'not be cancellable when 24 hours left to reservation' do
      travel_to(@reservation.starts_at - 24.hours) do
        @cancellation_policy = Reservation::CancellationPolicy.new(@reservation)
        refute @cancellation_policy.cancelable?
      end
    end

  end

end
