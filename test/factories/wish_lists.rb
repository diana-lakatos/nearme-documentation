FactoryGirl.define do
  factory :wish_list do
    name 'Favorites'
    association :user

    factory :default_wish_list do
      default true
    end
  end
end
