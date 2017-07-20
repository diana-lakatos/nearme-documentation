# frozen_string_literal: true
FactoryGirl.define do
  factory :stripe_payout, class: 'Stripe::Payout' do
    initialize_with { new(id: id) }

    id { 'py_123456789' }
    object 'payout'
    amount 40_000
    status 'paid'
  end
end
