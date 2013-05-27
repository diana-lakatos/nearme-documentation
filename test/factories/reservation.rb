FactoryGirl.define do
  factory :reservation do
    association :user
    association :listing
    date { Date.today }
    payment_status 'pending'
    quantity 1

    factory :reservation_with_valid_period do
      after(:create) do |reservation|
        make_valid_period(reservation).save!
      end

      after(:build) do |reservation|
        make_valid_period(reservation)
      end
    end

    factory :reservation_with_credit_card do
      payment_method 'credit_card'

      factory :reservation_with_credit_card_and_valid_period do
        after(:create) do |reservation|
          make_valid_period(reservation).save!
        end

        after(:build) do |reservation|
          make_valid_period(reservation)
        end
      end

    end
  end

end

private

def make_valid_period(reservation)
  reservation.periods = []
  reservation.add_period(Time.now.next_week.to_date)
  reservation
end
