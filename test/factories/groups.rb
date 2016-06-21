FactoryGirl.define do
  factory :group do
    sequence(:name) { |n| "Group #{n}" }
    summary 'Summary'
    description 'Description'

    association :creator, factory: :user
    association :group_type, factory: :public_group_type
  end
end
