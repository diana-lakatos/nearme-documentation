class LineItem::Transactable < LineItem

  before_create :build_service_fee, :build_host_fee

  delegate :price_calculator, to: :line_itemable
  delegate :creator_id, :transactable_type_id, to: :line_item_source, allow_nil: true

  before_validation :set_unit_price, if: lambda { line_itemable }

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

  def validate_transactable_quantity(order)
    unless sufficient_stock?
      order.errors.add :base,
        I18n.t("activerecord.errors.models.order.transactable_quantity",
          transactable_name: self.line_item_source.name)
    end
  end

  def reduce_transactable_quantity!
    self.line_item_source.update_attribute(:quantity, self.line_item_source.quantity - self.quantity)
  end

  def return_transactable_quantity!
    self.line_item_source.update_attribute(:quantity, self.line_item_source.quantity + self.quantity)
  end

  def build_service_fee
    return true if service_fee_guest_percent.to_f.zero?
    if self.line_itemable.service_fee_line_items.any?
      service_fee = self.line_itemable.service_fee_line_items.first
      service_fee.update_attribute(
        :unit_price_cents, service_fee.unit_price_cents + (total_price_cents * service_fee_guest_percent.to_f / BigDecimal(100))
      )
    else
      self.line_itemable.service_fee_line_items.build(
        line_itemable: self.line_itemable,
        line_item_source: current_instance,
        optional: false,
        receiver: "mpo",
        name: "Service Fee",
        quantity: 1,
        unit_price_cents: calculate_fee(service_fee_guest_percent),
        service_fee_guest_percent: service_fee_guest_percent,
        service_fee_host_percent: service_fee_host_percent,
      )
    end
  end

  def build_host_fee
    return true if service_fee_host_percent.to_f.zero?
    if self.line_itemable.host_fee_line_items.any?
      host_fee = self.line_itemable.host_fee_line_items.first
      host_fee.update_attribute(
        :unit_price_cents, host_fee.unit_price_cents + (total_price_cents * service_fee_host_percent.to_f / BigDecimal(100))
      )
    else
      self.line_itemable.host_fee_line_items.build(
        line_itemable: self.line_itemable,
        line_item_source: current_instance,
        unit_price_cents: calculate_fee(service_fee_host_percent)
      )
    end
  end

  private

  def calculate_fee(fee_percent)
    (total_price * fee_percent.to_f / BigDecimal(100)).to_money(currency).cents
  end

end
