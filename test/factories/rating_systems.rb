# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rating_system do
    instance
    subject { %w(transactable host guest).sample }
    transactable_type { TransactableType.first || FactoryGirl.create(:transactable_type) }
    active true
  end

  factory :not_active_rating_system, parent: :rating_system do
    active false
  end
end
