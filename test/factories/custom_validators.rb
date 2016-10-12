FactoryGirl.define do
  factory :custom_validator do
    field_name 'name'
    validatable { TransactableType.first || FactoryGirl.create(:transactable_type) }
    required 1
  end
end
