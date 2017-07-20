# frozen_string_literal: true
FactoryGirl.define do
  factory :stripe_transfer, class: 'Stripe::Transfer' do
    initialize_with { new(id: id) }

    id { 'tr_123456789' }
    object 'transfer'
    amount 40_000
    status 'paid'
  end
end
