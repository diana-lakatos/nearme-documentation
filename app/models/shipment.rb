class Shipment < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :order, inverse_of: :shipments

  belongs_to :instance
  belongs_to :shipping_rule
  # has_one :shipping_address
  # accepts_nested_attributes_for :shipping_address

  # validates :shippo_rate_id, :price, presence: true
  before_validation :set_attributes
  before_create :create_line_item
  before_save :change_line_item, if: :shipping_rule_id_changed?

  has_one :shipping_line_item, class_name: 'LineItem::Shipping', as: :line_item_source, dependent: :destroy

  delegate :shipping_address, to: :order
  delegate :is_pickup?, to: :shipping_rule

  scope :without_transaction, -> { where(shippo_transaction_id: nil) }
  scope :outbound, -> { where(direction: 'outbound') }
  scope :inbound, -> { where(direction: 'inbound') }
  scope :using_shippo, -> { joins(:shipping_rule).where('shipping_rules.use_shippo_for_price = true')}

  def get_rates(order)
    location_address = instance.shippo_api.create_address(address_from_hash(order))[:object_id]
    if outbound?
      address_from = location_address
      address_to = shipping_address.get_shippo_id
    else
      address_from = shipping_address.get_shippo_id
      address_to = location_address
    end
    parcel = order.transactable.dimensions_template.get_shippo_id
    shipment = instance.shippo_api.create_shipment(address_from, address_to, parcel, customs_declaration, insurance)
    rates = instance.shippo_api.get_rates_for_shipment(shipment)
  end

  def address_from_hash(order)
    location_address_hash = order.transactables.first.location.address_to_shippo
    location_address_hash[:company] = order.company.name
    location_address_hash
  end

  def valid_sending_company_address?(order)
    location_address = instance.shippo_api.create_address(address_from_hash(order))[:object_id]

    ShippoApi::ShippoAddressInfo.valid?(location_address)
  rescue
    false
  end

  def outbound?
    direction == 'outbound'
  end

  def inbound?
    direction == 'inbound'
  end

  def ready?
    tracking_number.present?
  end

  def change_line_item
    if shipping_line_item
      if shipping_rule.is_pickup?
        self.shipping_line_item.destroy
      else
        self.shipping_line_item.update(
          name: shipping_rule.name,
          unit_price_cents: shipping_rule.price_cents,
          quantity: 1
        )
      end
    end
  end

  def use_shippo?
    shipping_rule.try(:use_shippo_for_price?)
  end

  def create_line_item
    self.name = shipping_rule.name
    return if shipping_rule.is_pickup? || shipping_rule.use_shippo_for_price?
    self.shipping_line_item || self.build_shipping_line_item(line_itemable: order)
    self.shipping_line_item.update(
      name: name,
      unit_price_cents: shipping_rule.price_cents,
      quantity: 1
    )
  end

  def set_attributes
    if self.shippo_rate_id
      rate = instance.shippo_api.get_rate(shippo_rate_id)
      self.price = rate[:amount_cents]
      self.price_currency = rate[:currency]
      self.insurance_value = rate[:insurance_amount_cents]
      self.insurance_currency = rate[:insurance_currency]
      self.name = "#{rate[:provider]} #{rate[:servicelevel_name]}"
      self.name += ' - Return' if inbound?
      self.shipping_line_item || self.build_shipping_line_item(line_itemable: order)
      self.shipping_line_item.update(
        name: "#{I18n.t('order.shipping')}#{name}",
        unit_price_cents: rate[:amount_cents],
        quantity: 1
      )
    end
    true
  end

  def create_shippo_shipment!
    transaction = instance.shippo_api.create_transaction(shippo_rate_id)
    if transaction.present?
      if transaction[:object_status] == 'ERROR'
        self.shippo_errors = transaction[:messages].to_json
      else
        self.label_url = transaction[:label_url]
        self.tracking_number = transaction[:tracking_number]
        self.tracking_url_provider = transaction[:tracking_url_provider]
        self.shippo_transaction_id = transaction[:object_id]
      end
    end
    self.save
  end

  def insurance
    if is_insured && order.transactable.insurance_value.to_f > 0
      {
        insurance_amount: order.transactable.insurance_value.to_f,
        insurance_currency: order.transactable.currency,
        extra: {
          insurance_content: order.transactable.name
        }
      }
    else
      {}
    end
  end

  def customs_declaration
    nil
  end

  def to_liquid
    @shipment_drop ||= ShipmentDrop.new(self)
  end

end
