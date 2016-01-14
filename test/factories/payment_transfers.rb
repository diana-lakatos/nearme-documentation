# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment_transfer do
    company
    amount_cents 1234
    service_fee_amount_guest_cents 10
    service_fee_amount_host_cents 15
    currency 'USD'
    transferred_at "2013-07-17 14:44:29"

    after(:create) do |payment_transfer|
      payment_transfer.payout_attempts = [FactoryGirl.create(:payout)]
    end

    factory :payment_transfer_unpaid do
      transferred_at nil
    end
  end
end
