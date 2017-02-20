# frozen_string_literal: true
class LineItem::Transactable < LineItem
  before_create :build_service_fee, :build_host_fee

  delegate :price_calculator, to: :line_itemable
  delegate :creator_id, :transactable_type_id, to: :line_item_source, allow_nil: true

  before_validation :set_unit_price, if: -> { line_itemable }

  validate :validate_unit_price_cents

  before_create :store_properties

  def transactable
    line_item_source
  end

  def cart_position
    0
  end

  def deletable?
    true
  end

  def editable?
    !line_itemable.exclusive_price?
  end

  def set_unit_price
    self.quantity ||= line_itemable.quantity || 1
    self.unit_price ||= price_calculator.unit_price
  end

  def sufficient_stock?
    line_item_source.quantity >= quantity.to_i
  end

  def insufficient_stock?
    !sufficient_stock?
  end

  def validate_transactable_quantity(order)
    unless sufficient_stock?
      order.errors.add :base,
                       I18n.t('activerecord.errors.models.order.transactable_quantity',
                              transactable_name: line_item_source.name)
    end
  end

  def reduce_transactable_quantity!
    line_item_source.update_attribute(:quantity, line_item_source.quantity - self.quantity)
  end

  def return_transactable_quantity!
    line_item_source.update_attribute(:quantity, line_item_source.quantity + self.quantity)
  end

  def build_service_fee
    return true if (calculate_fee(service_fee_guest_percent) + first_shipping_cost).zero?

    if line_itemable.service_fee_line_items.any?
      service_fee = line_itemable.service_fee_line_items.first
      service_fee.update_attribute(
        :unit_price_cents, calculate_fee(service_fee_guest_percent) + first_shipping_cost
      )
    else
      if line_itemable.persisted?
        line_itemable.service_fee_line_items.create(service_fee_attributes)
      else
        line_itemable.service_fee_line_items.build(service_fee_attributes)
      end
    end
  end

  def service_fee_attributes
    {
      line_itemable: line_itemable,
      line_item_source: current_instance,
      optional: false,
      receiver: 'mpo',
      name: 'Service Fee',
      quantity: 1,
      unit_price_cents: calculate_fee(service_fee_guest_percent) + first_shipping_cost,
      service_fee_guest_percent: service_fee_guest_percent,
      service_fee_host_percent: service_fee_host_percent
    }
  end

  def build_host_fee
    return true if (calculate_fee(service_fee_host_percent) + second_shipping_cost).zero?

    if line_itemable.host_fee_line_items.any?
      host_fee = line_itemable.host_fee_line_items.first
      host_fee.update_attribute(
        :unit_price_cents, calculate_fee(service_fee_host_percent, current_fee: host_fee.unit_price_cents, minimum: minimum_lister_service_fee_cents) + second_shipping_cost
      )
    else
      if line_itemable.persisted?
        line_itemable.host_fee_line_items.create(host_fee_attributes)
      else
        line_itemable.host_fee_line_items.build(host_fee_attributes)
      end
    end
  end

  def host_fee_attributes
    {
      line_itemable: line_itemable,
      line_item_source: current_instance,
      unit_price_cents: calculate_fee(service_fee_host_percent, minimum: minimum_lister_service_fee_cents) + second_shipping_cost
    }
  end

  private

  def validate_unit_price_cents
    errors.add :unit_price, :equal_to, count: 0 if !unit_price_cents.zero? && line_itemable && line_itemable.is_free_booking?
  end

  def calculate_fee(fee_percent, options = { current_fee: 0, minimum: 0 })
    return 0 if fee_percent.to_f.zero?
    [options[:current_fee].to_i + (total_price * fee_percent.to_f / BigDecimal(100)).to_money(currency).cents, options[:minimum].to_i].max
  end

  def first_shipping_cost
    line_itemable.shipping_line_items.first&.unit_price_cents || 0
  end

  def second_shipping_cost
    line_itemable.shipping_line_items.second&.unit_price_cents || 0
  end

  def store_properties
    self.properties = line_item_source.try(:properties).try(:to_h).try(:to_json)
    true
  end
end
