# frozen_string_literal: true
class WishListItem < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  PERMITTED_CLASSES = %w(Location Transactable User).freeze

  class NotPermitted < StandardError
  end

  class Disabled < StandardError
  end

  belongs_to :wishlistable, polymorphic: true, touch: true

  belongs_to :wish_list, touch: true
  has_one :user, through: :wish_list

  scope :by_date, -> { order 'created_at DESC' }

  after_create :increment_counters
  after_destroy :decrement_counters

  def to_liquid
    @wish_list_item_drop ||= WishListItemDrop.new(self)
  end

  private

  def increment_counters
    wishlistable.class.increment_counter 'wish_list_items_count', wishlistable_id if wishlistable
  end

  def decrement_counters
    wishlistable.class.decrement_counter 'wish_list_items_count', wishlistable_id if wishlistable
  end
end
