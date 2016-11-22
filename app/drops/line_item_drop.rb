# frozen_string_literal: true
class LineItemDrop < BaseDrop
  include CurrencyHelper

  # @return [LineItemDrop]
  attr_reader :line_item

  # @!method name
  #   Name for the line item / product
  #   @return (see LineItem#name)
  # @!method quantity
  #   Quantity being ordered
  #   @return (see LineItem#quantity)
  # @!method unit_price
  #   @return [MoneyDrop] unit price
  # @!method created_at
  #   @return [DateTime] when the line item was created
  delegate :name, :quantity, :unit_price, :created_at, to: :line_item

  def initialize(line_item)
    @line_item = line_item
  end

  # @return [String] formatted unit price rendered according to the global currency rendering rules
  def formatted_unit_price
    render_money(@line_item.unit_price)
  end

  # @return [String] formatted total price rendered according to the global currency rendering rules
  def formatted_total_price
    render_money(@line_item.total_price)
  end

  # @return [String] net price as a string
  def net_price
    @line_item.net_price.to_s
  end

  # @return [String] formatted net price rendered according to the global currency rendering rules
  def formatted_net_price
    render_money(@line_item.net_price)
  end

  # @return [String] gross price as a string
  def gross_price
    @line_item.gross_price.to_s
  end

  # @return [String] formatted gross price rendered according to the global currency rendering rules
  def formatted_gross_price
    render_money(@line_item.gross_price)
  end

  # @return [String] total price as a string
  def total_price
    @line_item.total_price.to_s
  end

  # @return [String] formatted total price rendered according to the global currency rendering rules
  def formatted_total_price
    render_money(@line_item.total_price)
  end

  # @return [String] last part of the class name of the line item
  def class_name
    @line_item.class.name.demodulize
  end

  # @return [Boolean] whether this line item represents a service fee
  def is_service_fee?
    @line_item.is_service_fee?
  end
end
