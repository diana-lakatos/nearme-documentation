FactoryGirl.define do
  factory :reservation do
    association :user
    association :listing, factory: :transactable
    association :payment_method, factory: :manual_payment_method
    date { Time.zone.today }
    payment_status 'pending'
    quantity 1
    state 'unconfirmed'
    platform_context_detail_type "Instance"
    platform_context_detail_id { PlatformContext.current.instance.id }
    time_zone { Time.zone.name }

    before(:create) do |reservation|
      make_valid_period(reservation).save! unless reservation.valid?
    end

    after(:build) do |reservation|
      make_valid_period(reservation) unless reservation.valid?
    end

    after(:create) do |reservation|
      reservation.starts_at = reservation.first_period.starts_at
      reservation.ends_at = reservation.last_period.ends_at
      reservation.save!
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
          period.date = Date.tomorrow + i.days
          period.save!
        end
        reservation.starts_at = reservation.first_period.starts_at
        reservation.ends_at = reservation.last_period.ends_at
        reservation.save!
      end
    end

    factory :past_reservation do
      state 'confirmed'

      after(:create) do |reservation|
        reservation.periods.reverse.each_with_index do |period, i|
          period.date = Date.yesterday - i.days
          period.save!
        end
        reservation.starts_at = reservation.first_period.starts_at
        reservation.ends_at = reservation.last_period.ends_at
        reservation.save!
      end
    end
  end
end

private

def make_valid_period(reservation)
  reservation.periods = []
  reservation.add_period(Time.zone.now.next_week.to_date)
  reservation
end
