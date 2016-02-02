FactoryGirl.define do
  factory :reservation_without_payment, class: Reservation do
    association :user
    association :listing, factory: :transactable
    date { Time.zone.now.next_week.to_date }
    payment_status 'pending'
    quantity 1
    state 'inactive'
    platform_context_detail_type "Instance"
    platform_context_detail_id { PlatformContext.current.instance.id }
    time_zone { Time.zone.name }
    service_fee_amount_host_cents 0
    service_fee_amount_guest_cents 0

    after(:build) do |reservation|
      make_valid_period(reservation) unless reservation.valid?
    end

    factory :inactive_reservation do
      after(:build) do |reservation|
        reservation.payment ||= FactoryGirl.build(:pending_payment, payable: reservation)
      end
    end

    factory :unconfirmed_reservation do
      state 'unconfirmed'
      payment_status 'authorized'
      expire_at { Time.zone.now.next_week.to_date }
      after(:build) do |reservation|
        reservation.payment ||= FactoryGirl.build(:authorized_payment, payable: reservation)
      end
    end

    factory :confirmed_reservation do
      state 'confirmed'
      payment_status 'paid'

      after(:build) do |reservation|
        reservation.payment ||= FactoryGirl.build(:paid_payment, payable: reservation)
      end
    end

    factory :reservation_with_remote_payment do
      association :listing, factory: :listing_in_auckland
      after(:build) do |reservation|
        reservation.payment ||= FactoryGirl.build(:remote_payment, payable: reservation)
      end
    end

    factory :reservation do
      after(:build) do |reservation, evaluator|
        if evaluator.payment
          evaluator.payment.payable = reservation
        else
          reservation.payment = FactoryGirl.build(:pending_payment, payable: reservation)
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

      factory :rejected_reservation do
        state 'rejected'
      end

      factory :cancelled_by_guest_reservation do
        state 'cancelled_by_guest'
      end

      factory :cancelled_by_host_reservation do
        state 'cancelled_by_host'
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
