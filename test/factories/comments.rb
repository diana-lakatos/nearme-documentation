FactoryGirl.define do
  factory :comment do
    body 'Comment body'
    association :creator, factory: :user
  end
end
