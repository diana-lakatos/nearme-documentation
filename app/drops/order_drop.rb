class OrderDrop < BaseDrop

  attr_reader :order

  # id
  #   numeric identifier for this order
  # user
  #   user object representing the user who has placed this order
  # company
  #   company object to which the ordering user belongs
  # number
  #   string representing the unique identifier for this order
  # line_items
  #   an array of line items that belong to this order in the form of LineItem objects
  #   line items contain one ordered product variant with its ordered quantity
  # line_item_adjustments
  #   returns an array of line item adjustment objects for this order's line items
  #   adjustments will either decrease an order's total (promotions) or will increase it
  #   (shipping, taxes etc.)
  delegate :id, :user, :company, :number, :line_items, :line_item_adjustments, :adjustment, to: :order

  def initialize(order)
    @order = order.decorate
  end

  def manual_payment?
    @order.payment.try(:manual_payment?)
  end

  # list of eligible adjustments for this order in the form of objects with the properties
  # label (label for the adjustment) and amount (amount of the adjustment)
  def eligible__adjustments
    @order.adjustments.eligible.inject([]) do |adj_info, adjustment|
      adj_info << { label: adjustment.label, amount: adjustment.display_amount.to_s }
    end
  end

  # returns a list of all adjustments in the form of objects having the properties
  # label (label for the adjustment), amount (amount of the adjustment), currency (currency for the order)
  def all_adjustment_summary
    adjustment_info = []
    @order.all_adjustments.promotion.eligible.group_by(&:label).each do |label, adjustments|
      adjustment_info << { label: label, amount: Spree::Money.new(adjustments.sum(&:amount), currency: @order.currency).to_s  }
    end
    adjustment_info
  end

  # list of shipment information objects for this order grouped by the selected shipping methods
  # has the properties: name - name of the selected shipping method, rate - total cost for this
  # shipping rate (all shipments included), currency - the currency for the order
  def grouped_shipments
    grouped_shipments = []
    @order.shipments.group_by { |s| s.selected_shipping_rate.try(:name) }.each do |name, shipments|
      grouped_shipments << { 'name' => name, 'rate' =>  Spree::Money.new(shipments.sum(&:discounted_cost), currency: @order.currency).to_s }
    end
    grouped_shipments
  end

  # list of tax information objects for this order grouped by the tax name (type)
  # has the properties: label - label for this particular type of tax, amount: total amount for this
  # particular type of tax, currency - currency for the order
  def taxes
    taxes = []
    @order.all_adjustments.eligible.tax.group_by(&:label).each do |label, adjustments|
      taxes << { label: label, amount: Spree::Money.new(adjustments.sum(&:amount), currency: @order.currency).to_s }
    end
    taxes
  end

  # list of adjustment information objects (other than tax adjustments) for this order, grouped by 
  # their type; has the properties: label - label for this particular adjustment, amount - total 
  # amount for this particular adjustment
  def other_adjustments
    @order.adjustments.eligible.inject([]) do |other_adjustments, adjustment|
      if (adjustment.source_type != 'Spree::TaxRate') && (adjustment.amount > 0)
        other_adjustments << { label: adjustment.label, amount: adjustment.display_amount.to_s }
      end
      other_adjustments
    end
  end

  # the guest part of the service fee for this particular order
  def service_fee_amount_guest
    @order.service_fee_amount_guest.to_s
  end

  # the total amount to be charged for this order
  def total_amount
    @order.total_amount.to_s
  end

  # total for this item as a string including the currency symbol
  def display_item_total
    @order.display_item_total.to_s
  end

  # whether or not the order has products with seller attachments
  def has_seller_attachments?
    @order.transactable_line_items.each do |line_item|
      return true if line_item.line_item_source.attachments.exists?
    end

    false
  end

end
