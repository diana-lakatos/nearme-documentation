FactoryGirl.define do
  factory :reservation do
    association :user
    association :listing, factory: :transactable
    association :payment_method, factory: :manual_payment_method
    date { Time.zone.today }
    payment_status 'pending'
    quantity 1
    state 'inactive'
    platform_context_detail_type "Instance"
    platform_context_detail_id { PlatformContext.current.instance.id }
    time_zone { Time.zone.name }

    before(:create) do |reservation|
      make_valid_period(reservation).save! unless reservation.valid?
    end

    after(:build) do |reservation|
      make_valid_period(reservation) unless reservation.valid?
    end

    factory :authorized_reservation do
      after(:create) do |reservation|
        reservation.mark_as_authorized!
      end

      factory :confirmed_reservation do
        after(:create) do |reservation|
          reservation.confirm!
        end
      end
    end

    factory :lasting_reservation do
      after(:create) do |reservation|
        reservation.periods.destroy_all
        make_valid_period(
          reservation,
          Time.now.in_time_zone(reservation.time_zone).to_date,
          Time.now.in_time_zone(reservation.time_zone).to_minutes - 60,
          Time.now.in_time_zone(reservation.time_zone).to_minutes + 60
        )
        reservation.save!
      end
    end

    factory :reservation_hourly do
      reservation_type 'hourly'
    end

    factory :reservation_with_credit_card do
      association :payment_method, factory: :credit_card_payment_method
    end

    factory :reservation_with_remote_payment do
      association :listing, factory: :listing_in_auckland
      association :payment_method, factory: :remote_payment_method
      after(:create) do |reservation|
        FactoryGirl.create(:billing_authorization, reference: reservation)
      end
    end

    factory :reservation_in_san_francisco do
      association(:listing, factory: :listing_in_san_francisco_address_components)
    end

    factory :future_reservation do
      after(:create) do |reservation|
        reservation.periods.reverse.each_with_index do |period, i|
          period.date = Date.today.next_week + i.days
          period.save!
        end
        reservation.save!
      end

      factory :future_unconfirmed_reservation do
        after(:create) do |reservation|
          reservation.mark_as_authorized!
        end

        factory :future_confirmed_reservation do
          after(:create) do |reservation|
            reservation.confirm!
          end
        end

      end
    end

    factory :expired_reservation do
      after(:create) do |reservation|
        reservation.mark_as_authorized!
        reservation.expire!
        reservation.periods.reverse.each_with_index do |period, i|
          period.date = Date.yesterday - i.days
          period.save!
        end
        reservation.save!
      end
    end


    factory :past_reservation do
      after(:create) do |reservation|
        reservation.mark_as_authorized!
        reservation.confirm!
        reservation.periods.reverse.each_with_index do |period, i|
          period.date = Date.yesterday - i.days
          period.save!
        end
        reservation.save!
      end
    end
  end
end

private

def make_valid_period(reservation, date=Time.zone.now.next_week.to_date, start_minute = nil, end_minute = nil)
  reservation.periods = []
  reservation.add_period(date, start_minute, end_minute)
  reservation
end
