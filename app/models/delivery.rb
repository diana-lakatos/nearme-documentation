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

  has_many :external_states, class_name: 'Shippings::DeliveryExternalState'
  has_one :external_state, -> { order 'created_at desc' }, class_name: 'Shippings::DeliveryExternalState'

  accepts_nested_attributes_for :sender_address, :receiver_address

  delegate :suburb, :postcode, to: :sender_address, prefix: true
  delegate :suburb, :postcode, to: :receiver_address, prefix: true
  delegate :weight, to: :dimensions_template
  delegate :tracking_url, :labels, to: :current_state

  validates :dimensions_template, presence: true

  def external_order_id
    current_state.order_id
  end

  def state
    current_state.state || self[:state]
  end

  def current_state
    external_state || Shippings::DeliveryExternalState.new
  end

  def to_liquid
    DeliveryDrop.new(self)
  end
end
