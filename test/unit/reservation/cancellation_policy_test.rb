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
      travel_to(Time.zone.now - 1.day) { assert @cancellation_policy.cancelable? }
    end

    should 'not be cancellable when 24 hours left to reservation' do
      travel_to((Time.use_zone(Time.zone) { Time.zone.local_to_utc(@reservation.date + @reservation.first_period.start_minute.minutes) }.localtime) - 24.hours) { refute @cancellation_policy.cancelable? }
    end

  end

end
