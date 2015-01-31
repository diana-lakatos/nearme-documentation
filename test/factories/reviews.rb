# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :review do
    rating { rand(RatingConstants::VALID_VALUES) }
    object %w(product seller buyer).sample
    user
    instance { Instance.first.presence || FactoryGirl.create(:instance) }
  end
end
