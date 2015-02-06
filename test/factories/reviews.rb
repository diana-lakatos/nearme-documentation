# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :review do
    rating { rand(RatingConstants::VALID_VALUES) }
    object RatingConstants::FEEDBACK_TYPES.sample
    user
    instance { Instance.default_instance.presence || FactoryGirl.create(:instance) }
    reviewable { FactoryGirl.create(:reservation, instance: instance)  }
    transactable_type { instance.transactable_types.first }
  end
end
