class WishListItem < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :wishlistable, polymorphic: true

  belongs_to :wish_list
  has_one :user, through: :wish_list

  scope :by_date, -> { order 'created_at DESC' }

  after_create :increment_counters
  after_destroy :decrement_counters

  [:increment, :decrement].each do |type|
    define_method("#{type}_counters") do
      wishlistable_type.classify.constantize.send("#{type}_counter", 'wish_list_items_count'.to_sym,
                                                  self.wishlistable_id)
    end
  end
end
