FactoryGirl.define do
  factory :custom_model_type do
    name 'MyString'
    instance { PlatformContext.current.try(:instance) || Instance.first }
    transactable_types { TransactableType.all }
  end
end
