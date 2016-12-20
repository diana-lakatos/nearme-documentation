# frozen_string_literal: true
# TODO: duplicates shipping model
class Delivery < ActiveRecord::Base
  include Validatable

  has_paper_trail
  acts_as_paranoid
  scoped_to_platform_context
  auto_set_platform_context

  belongs_to :sender_address, class_name: OrderAddress
  belongs_to :receiver_address, class_name: OrderAddress
  belongs_to :order, inverse_of: :deliveries
  belongs_to :dimensions_template

  accepts_nested_attributes_for :sender_address, :receiver_address

  delegate :suburb, :postcode, to: :sender_address, prefix: true
  delegate :suburb, :postcode, to: :receiver_address, prefix: true

  validates :dimensions_template, presence: true

  def weight
    dimensions_template.weight
  end

  def to_liquid
    DeliveryDrop.new(self)
  end
end
