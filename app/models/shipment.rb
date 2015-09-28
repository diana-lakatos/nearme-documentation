class Shipment < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :reservation
  belongs_to :instance
  has_one :shipping_address
  accepts_nested_attributes_for :shipping_address

  validates :shippo_rate_id, :price, presence: true
  before_validation :set_attributes, on: :create

  scope :without_transaction, -> { where(shippo_transaction_id: nil) }
  scope :outbound, -> { where(direction: 'outbound') }
  scope :inbound, -> { where(direction: 'inbound') }

  def get_rates(reservation)
    api = ShippoApi::ShippoApi.new(instance.shippo_api_token)
    if outbound?
      address_from = api.create_address(ShippoApi::ShippoFromAddressFillerFromSpree.new(reservation.company))[:object_id]
      address_to = shipping_address.get_shippo_id
    else
      address_from = shipping_address.get_shippo_id
      address_to = api.create_address(ShippoApi::ShippoFromAddressFillerFromSpree.new(reservation.company))[:object_id]
    end
    parcel = reservation.listing.dimensions_template.get_shippo_id
    shipment = api.create_shipment(address_from, address_to, parcel)
    rates = api.get_rates_for_shipment(shipment)
  end

  def direction
    super || 'outbound'
  end

  def outbound?
    direction == 'outbound'
  end

  def set_attributes
    api = ShippoApi::ShippoApi.new(instance.shippo_api_token)
    rate = api.get_rate(shippo_rate_id)
    self.price = rate[:amount_cents]
    self.price_currency = rate[:currency]
    self.insurance_value = rate[:insurance_amount_cents]
    self.insurance_currency = rate[:insurance_currency]
  end

  def create_shippo_shipment!
    api = ShippoApi::ShippoApi.new(instance.shippo_api_token)
    transaction = api.create_transaction(shippo_rate_id)
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

end
