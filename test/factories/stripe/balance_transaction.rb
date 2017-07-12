# frozen_string_literal: true
FactoryGirl.define do
  factory :stripe_balance_transaction, class: 'Stripe::BalanceTransaction' do
    initialize_with { new(id: id) }
    id { 'txn_Ay4uOAxuiKVcFg' }
    object "balance_transaction"
    amount 24804
    available_on 1498694400
    created 1498002905
    currency "usd"
    description 'Bla bla bla'
    fee 3513
    fee_details [ {"amount":3513, "application":"ca_94QvFiF2FnJNWAr4A8wKBeJ2uk1XESvY","currency":"aud","description":" application fee","type":"application_fee"}]
    net 21291
    status "available"

    factory :stripe_charge_balance_transaction do
      source "ch_1AWwBZJeqgicvUpHOarUkw34"
      type "charge"
    end

    factory :stripe_payment_balance_transaction do
      source "py_1AWwBZJeqgicvUpHOarUkw34"
      type "payment"
    end
  end
end
