class OrderDrop < BaseDrop
  include CurrencyHelper

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
  delegate :id, :user, :company, :number, :line_items, :total_units_text, to: :order

  def initialize(order)
    @order = order.decorate
  end

  def manual_payment?
    @order.payment.try(:manual_payment?)
  end

  # the guest part of the service fee for this particular order
  def service_fee_amount_guest
    @order.service_fee_amount_guest.to_s
  end

  # the total amount to be charged for this order
  def total_amount
    @order.total_amount.to_s
  end

  def formatted_total_amount
    humanized_money_with_cents_and_symbol(@order.total_amount)
  end

  # whether or not the order has products with seller attachments
  def has_seller_attachments?
    @order.transactable_line_items.each do |line_item|
      return true if line_item.line_item_source.attachments.exists?
    end

    false
  end

  def included_tax?
    @first_line_item =
    first_line_item.included_tax_total_rate.zero? == false
  end

  def additional_tax?
    first_line_item.additional_tax_total_rate.zero? == false
  end

  private
    def first_line_item
      @first_line_item ||= @order.line_items.first || OpenStruct.new(included_tax_total_rate: 0, additional_tax_total_rate: 0)
      @first_line_item
    end

end
