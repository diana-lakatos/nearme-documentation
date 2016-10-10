FactoryGirl.define do
  factory :document_requirement do
    label 'ID'
    description 'Please provide your ID'
    item { FactoryGirl.create(:transactable) }
  end
end
