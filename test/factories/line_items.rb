FactoryGirl.define do
  factory :line_item do
    association :user
    association :line_itemable, factory: :reservation
    association :line_item_source, factory: :transactable

    factory :transactable_line_item, class: LineItem::Transactable do
      name 'Something cool'
      unit_price 10.23
      quantity 1
      receiver 'mpo'
      optional false
    end

    factory :additional_line_items, class: LineItem::Additional do
      name 'Something cool'
      unit_price 10.23
      quantity 1
      receiver 'mpo'
      optional false
    end
  end
end
