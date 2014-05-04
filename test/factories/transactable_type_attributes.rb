FactoryGirl.define do
  factory :transactable_type_attribute do
    sequence(:name) { |n| "Attribute #{n}" }
    html_tag "input"
  end
end
