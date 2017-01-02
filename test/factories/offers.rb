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
        {
          transactable_id: transactable.id,
          transactable_pricing_id: transactable.action_type.pricing.id
        }
      )
    end

    factory :unconfirmed_offer do
      state 'unconfirmed'
    end
  end
end
