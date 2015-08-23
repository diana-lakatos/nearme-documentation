FactoryGirl.define do
  factory :recurring_booking do
    association :owner, factory: :user
    association :listing, factory: :transactable
    start_on { Time.zone.now.next_week }
    end_on { (Time.zone.now + 1.week).next_week + 3.days }
    start_minute nil
    end_minute nil
    schedule_params { { validations: { day: [1, 2, 3] }, rule_type: "IceCube::WeeklyRule", interval: 1, week_start: 0 } }
    platform_context_detail_type "Instance"
    platform_context_detail_id { PlatformContext.current.instance.id }
    quantity 1
    state 'unconfirmed'

    after(:build) do |recurring_booking|
      recurring_booking.schedule.occurrences(recurring_booking.end_on).each do |date|
        r = FactoryGirl.build(:reservation, recurring_booking: recurring_booking, owner: recurring_booking.owner, listing: recurring_booking.listing)
        r.periods.first.date = date
        recurring_booking.reservations << r
      end
    end

    factory :recurring_booking_hourly do
      start_minute 540
      end_minute 600
    end
  end

end

