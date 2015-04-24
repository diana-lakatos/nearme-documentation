class Spree::OrderDrop < BaseDrop

  attr_reader :order
  delegate :id, :user, :company, :number, :line_items, :line_item_adjustments, :adjustment, :manual_payment?, to: :order

  def initialize(order)
    @order = order.decorate
  end

  def eligible__adjustments
    @order.adjustments.eligible.inject([]) do |adj_info, adjustment|
      adj_info << { label: adjustment.label, amount: adjustment.display_amount.to_s }
    end
  end

  def all_adjustment_summary
    adjustment_info = []
    @order.all_adjustments.promotion.eligible.group_by(&:label).each do |label, adjustments|
      adjustment_info << { label: label, amount: Spree::Money.new(adjustments.sum(&:amount), currency: @order.currency).to_s  }
    end
    adjustment_info
  end

  def grouped_shipments
    grouped_shipments = []
    @order.shipments.group_by { |s| s.selected_shipping_rate.try(:name) }.each do |name, shipments|
      grouped_shipments << { 'name' => name, 'rate' =>  Spree::Money.new(shipments.sum(&:discounted_cost), currency: @order.currency).to_s }
    end
    grouped_shipments
  end

  def taxes
    taxes = []
    @order.all_adjustments.eligible.tax.group_by(&:label).each do |label, adjustments|
      taxes << { label: label, amount: Spree::Money.new(adjustments.sum(&:amount), currency: @order.currency).to_s }
    end
    taxes
  end

  def other_adjustments
    @order.adjustments.eligible.inject([]) do |other_adjustments, adjustment|
      if (adjustment.source_type != 'Spree::TaxRate') && (adjustment.amount > 0)
        other_adjustments << { label: adjustment.label, amount: adjustment.display_amount.to_s }
      end
      other_adjustments
    end
  end

  def service_fee_amount_guest
    Spree::Money.new(@order.service_fee_amount_guest, currency: @order.currency).to_s
  end

  def total_amount_to_charge
    Spree::Money.new(@order.total_amount_to_charge, currency: @order.currency).to_s
  end

  def display_item_total
    @order.display_item_total.to_s

  end


end
