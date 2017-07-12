# frozen_string_literal: true
FactoryGirl.define do
  factory :customization do
    custom_model_type
    customizable { FactoryGirl.create(:transactable)}
    user
    instance { PlatformContext.current.try(:instance) || Instance.first }

    after(:build) do |customization|
      customization.custom_attachments << FactoryGirl.create(:custom_attachment, owner: customization)
    end
  end
end
