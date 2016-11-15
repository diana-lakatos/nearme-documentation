# package template
class DimensionsTemplate < ActiveRecord::Base
  include ShippoLegacy::DimensionsTemplate

  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  belongs_to :instance
  belongs_to :shipping_provider, class_name: 'Shippings::ShippingProvider'
  belongs_to :entity, polymorphic: true

  validates :weight, :height, :width, :depth, presence: true, numericality: { greater_than: 0 }

  def to_liquid
    DimensionsTemplateDrop.new(self)
  end
end
