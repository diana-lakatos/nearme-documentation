# frozen_string_literal: true
FactoryGirl.define do
  factory :reservation_without_payment, class: Reservation do
    association :user
    association :transactable
    company { transactable.try(:company) || FactoryGirl.build(:company) }
    creator { transactable.creator }
    date { Time.zone.now.next_week.to_date }
    quantity 1
    state 'inactive'
    time_zone { Time.zone.name }
    currency 'USD'
    # service_fee_amount_host_cents 0
    # service_fee_amount_guest_cents 0

    after(:build) do |reservation|
      reservation.transactable_pricing ||= reservation.transactable.action_type.pricings.first
      make_valid_period(reservation) unless reservation.valid?
    end

    factory :confirmed_hour_reservation do
      state 'confirmed'

      after(:build) do |reservation|
        reservation.transactable_pricing = reservation.transactable.action_type.hour_pricings.first
        reservation.instance_variable_set('@price_calculator', nil)
        make_valid_period(reservation, Time.zone.now.next_week.to_date + 1.day, 600, 660)
        reservation.payment ||= FactoryGirl.build(:pending_payment, payable: reservation)
      end

      factory :confirmed_delayed_hour_reservation, class: DelayedReservation do
        after(:build) do |_reservation|
        end
      end
    end

    factory :inactive_reservation do
      after(:build) do |reservation|
        reservation.payment ||= FactoryGirl.build(:pending_payment, payable: reservation)
      end
    end

    factory :unconfirmed_reservation do
      state 'unconfirmed'
      expires_at { Time.zone.now.next_week.to_date }
      after(:build) do |reservation|
        reservation.payment ||= FactoryGirl.build(:authorized_payment, payable: reservation)
      end

      factory :expired_reservation do
        state 'expired'
        after(:create) do |reservation|
          reservation.periods.reverse.each_with_index do |period, i|
            period.date = Date.yesterday - i.days
            period.save!
          end
          reservation.save!
        end
      end
      factory :unconfirmed_delayed_reservation, class: DelayedReservation do
      end
    end

    factory :confirmed_reservation do
      state 'confirmed'

      after(:build) do |reservation|
        reservation.payment ||= FactoryGirl.build(:paid_payment, payable: reservation)
      end

      factory :past_reservation do
        after(:create) do |reservation|
          reservation.periods.reverse.each_with_index do |period, i|
            period.date = Date.yesterday - i.days
            period.save!
          end
          reservation.save!
        end

        factory :reviewable_reservation do
          archived_at { Time.zone.now - 1.minute }
        end
      end

      factory :reservation_with_invoice do
        state 'confirmed'
        after(:build) do |reservation|
          reservation.payment ||= FactoryGirl.build(:authorized_payment, payable: reservation)
          reservation.additional_line_items = [FactoryGirl.build(:additional_line_items)]
        end
      end
    end

    factory :reservation_with_remote_payment do
      association :transactable, factory: :listing_in_auckland
      state 'unconfirmed'
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
        association(:transactable, factory: :listing_in_san_francisco_address_components)
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

    factory :lasting_reservation do
      after(:build) do |reservation|
        reservation.payment ||= FactoryGirl.build(:paid_payment, payable: reservation)
      end

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

    factory :future_reservation do
      after(:create) do |reservation|
        reservation.periods.reverse.each_with_index do |period, i|
          period.date = Date.today.next_week + i.days
          period.save!
        end
        reservation.save!
      end

      factory :future_unconfirmed_reservation do
        state 'unconfirmed'
        expires_at { Time.zone.now.next_week.to_date }
        after(:build) do |reservation|
          reservation.payment ||= FactoryGirl.build(:authorized_payment, payable: reservation)
        end

        factory :future_confirmed_reservation do
          after(:create, &:confirm!)
        end
      end
    end
  end
end

private

def make_valid_period(reservation, date = Time.zone.now.next_week.to_date, start_minute = nil, end_minute = nil, _options = {})
  reservation.periods = []
  reservation.add_period(date, start_minute, end_minute)
  reservation
end
