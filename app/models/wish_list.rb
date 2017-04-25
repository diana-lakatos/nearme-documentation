class WishList < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  has_many :items, class_name: 'WishListItem'

  validates :name, presence: true

  scope :default, -> { where default: true }
end
