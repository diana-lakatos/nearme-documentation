# frozen_string_literal: true
FactoryGirl.define do
  factory :offer do
    type 'Offer'
    user { User.last || FactoryGirl.build(:enquirer) }
    state 'inactive'
    time_zone { Time.zone.name }
    currency 'USD'

    before(:create) do |offer, _|
      transactable = Transactable.last || FactoryGirl.create(:transactable_offer)
      offer.add_line_item!(
        transactable_id: transactable.id,
        transactable_pricing_id: transactable.action_type.pricing.id
      )
    end

    factory :unconfirmed_offer do
      state 'unconfirmed'
    end

    factory :confirmed_offer do
      state 'confirmed'
      after(:build) do |offer, _|
        offer.payment_subscription = build(:payment_subscription, payer: offer.user)
      end

      after(:create) do |offer, _|
        offer.transactable.update_attribute(:state, 'in_progress')
      end

      factory :offer_with_expenses do
        after(:build) do |offer, _|
          offer.order_items = build_list(:order_item, 2, order: offer)
        end
      end
    end
  end
end
