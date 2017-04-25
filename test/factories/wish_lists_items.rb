FactoryGirl.define do
  factory :wish_list_item do
    association :wish_list
    association :wishlistable, factory: :user
  end
end
