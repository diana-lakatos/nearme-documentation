FactoryGirl.define do
  factory :reservation do
    association :user
    association :listing
    date { Date.today }
    payment_status 'pending'
    quantity 1

    before(:create) do |reservation|
      make_valid_period(reservation).save! unless reservation.valid?
    end

    after(:build) do |reservation|
      make_valid_period(reservation) unless reservation.valid?
    end

    factory :reservation_with_credit_card do
      payment_method 'credit_card'
    end
  end

end

private

def make_valid_period(reservation)
  reservation.periods = []
  reservation.add_period(Time.now.next_week.to_date)
  reservation
end
