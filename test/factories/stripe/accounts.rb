# frozen_string_literal: true
FactoryGirl.define do
  factory :stripe_account, class: 'Stripe::Account' do
    initialize_with { Stripe::Account.construct_from(id: id, legal_entity: legal_entity) }
    id { 'acct_123456789' }
    legal_entity {{ first_name:  'Tomasz', verification: verification }}
    verification {{
      disabled_reason: nil,
      due_by: nil,
      fields_needed: [],
      details_code: nil
    }}
    object 'account'
    business_name 'Stripe.com'
    transfers_enabled true
    charges_enabled true
    country 'US'
    default_currency 'usd'
    display_name 'Stripe.com'
    email 'site@stripe.com'
    type 'standard'
  end
end
