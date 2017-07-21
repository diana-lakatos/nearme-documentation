# frozen_string_literal: true
FactoryGirl.define do
  factory :custom_model_type do
    name 'MyString'
    instance { PlatformContext.current.try(:instance) || Instance.first }
    transactable_types { TransactableType.all }

    factory :custom_model_type_offer_files do
      name 'offer_files'
      parameterized_name 'offer_files'
      after(:build) do |custom_model|
        custom_model.custom_attributes << FactoryGirl.build(:custom_attribute, attribute_type: 'file', name: 'offer_file', target: custom_model)
      end
    end

    factory :custom_model_type_refer_contact do
      name 'refer_contact'
      parameterized_name 'refer_contact'
      after(:build) do |custom_model|
        custom_model.transactable_types = []
        custom_model.custom_attributes << FactoryGirl.build(:custom_attribute, name: 'enquirer_name')
        custom_model.custom_attributes << FactoryGirl.build(:custom_attribute, name: 'enquirer_email')
      end
    end
  end
end
