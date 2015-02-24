FactoryGirl.define do
  factory :document_requirement do
    label "ID"
    description "Please provide your ID"
    item { FactoryGirl.create(:transactable) }

    factory :document_requirement_for_product do
      item { FactoryGirl.create(:base_product) }
    end
  end
end
