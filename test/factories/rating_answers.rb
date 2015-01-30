# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rating_answer do
    rating { rand(RatingConstants::VALID_VALUES) }
    rating_question
    review
  end
end
