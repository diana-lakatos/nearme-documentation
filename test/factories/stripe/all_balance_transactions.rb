# frozen_string_literal: true
FactoryGirl.define do
  factory :stripe_balance_transaction_all, class: 'Stripe::ListObject' do
    initialize_with { new(id: id) }
    id { 'txn_Ay4uOAxuiKVcFg' }
    object "list"
    url "/v1/balance/history"
    has_more false

  end
end
