# frozen_string_literal: true
FactoryGirl.define do
  factory :order_item, class: RecurringBookingPeriod do
    after(:build) do |order_item, _|
      transactable = Transactable.last || FactoryGirl.build(:transactable_offer_with_collaborator)
      order_item.line_items = build_list(:transactable_line_item, 3,
        line_itemable: order_item, line_item_source: transactable)
    end

    after(:create) do |order_item, _|
      # This is temporary hack for acter cureate callback in payable
      # we should remove aftter create callback and below
      order_item.line_items.destroy_all
    end
  end
end
