FactoryGirl.define do
  factory :purchase do
    type 'Purchase'
    association :user, name: 'Order'
    association :shipping_address, factory: :order_address
    association :billing_address, factory: :order_address
    currency { Currency.find_by_iso_code("USD") || FactoryGirl.build(:currency)}
    state 'inactive'
    use_billing false

    after(:build) do |purchase|
      purchase.transactable_line_items = [FactoryGirl.build(:transactable_line_item, line_itemable: purchase)]
    end

    factory :purchase_with_payment do
      after(:build) do |purchase|
        purchase.payment ||= FactoryGirl.build(:pending_payment, payable: purchase)
      end
    end
  end
end
