# TODO: duplicates shipping model
class Delivery < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  scoped_to_platform_context
  auto_set_platform_context

  belongs_to :sender_address, class_name: OrderAddress
  belongs_to :receiver_address, class_name: OrderAddress
  belongs_to :order, inverse_of: :deliveries

  accepts_nested_attributes_for :sender_address, :receiver_address

  delegate :city, :postcode, to: :sender_address, prefix: true
  delegate :city, :postcode, to: :receiver_address, prefix: true

  validates :notes, presence: true
  validates :sender_address, :receiver_address, presence: true
  validates_with Deliveries.validator

  # validate delivery number
  # validates :order_id, uniqueness: {scope: [:pickup_date]}

  def notes
    'no notes'
  end

  def weight
    order.transactable.dimensions_template.weight
  end

  def to_liquid
    DeliveryDrop.new(self)
  end
end
