# frozen_string_literal: true
FactoryGirl.define do
  factory :stripe_event, class: 'Stripe::Event' do
    initialize_with { new(id: id) }
    id { 'ev_123456789' }
    created 1_326_853_478
    livemode false
    # id "evt_#{Random.new_seed}"
    object 'event'
    request nil
    pending_webhooks 1
    api_version '2013-12-03'
    # data: hash_to_object({"object": options[:data] || transfer_response(options)})
  end
end
