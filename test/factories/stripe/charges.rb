# frozen_string_literal: true
FactoryGirl.define do
  factory :stripe_charge, class: 'Stripe::Charge' do
    initialize_with { new(id: id) }

    id { 'ch_123456789' }
    object 'charge'
    amount 40_000
    status 'paid'
  end
end
