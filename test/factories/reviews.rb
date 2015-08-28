# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :review do
    rating { rand(RatingConstants::VALID_VALUES) }
    association(:reviewable, factory: :reservation)
    rating_system
    transactable_type { TransactableType.first }
    user

    factory :order_review do
      reviewable { FactoryGirl.create(:order_with_line_items, instance: instance).line_items.first  }
    end
  end
end
