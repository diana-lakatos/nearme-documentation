class ShippingProfile < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  has_many :shipping_rules
  has_many :transactables
  belongs_to :instance
  belongs_to :company
  belongs_to :user
  belongs_to :partner

  accepts_nested_attributes_for :shipping_rules, reject_if: :all_blank, allow_destroy: true

  scope :global, -> { where(global: true) }

  SHIPPING_TYPES = %w(predefined shippo_single shippo_return).freeze

  SHIPPING_TYPES.each do |type|
    define_method("#{type}?") { shipping_type == type }
  end

  def shippo?
    shipping_type =~ /shippo/
  end

  def to_liquid
    @shipping_profile_drop ||= ShippingProfileDrop.new(self)
  end

end
