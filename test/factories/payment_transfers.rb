# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment_transfer do
    company
    payment_gateway_mode 'test'
    amount_cents 1234
    service_fee_amount_guest_cents 10
    service_fee_amount_host_cents 15
    currency 'USD'
    transferred_at '2013-07-17 14:44:29'
    token 'tokenowski'

    after(:create) do |payment_transfer|
      payment_transfer.payout_attempts = [FactoryGirl.create(:payout, reference: payment_transfer)]
    end

    factory :payment_transfer_unpaid do
      transferred_at nil

      after(:create) do |payment_transfer|
        payment_transfer.payout_attempts = [FactoryGirl.create(:pending_payout, reference: payment_transfer)]
      end
    end
  end
end
