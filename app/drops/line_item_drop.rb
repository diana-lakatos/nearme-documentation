class LineItemDrop < BaseDrop
  include CurrencyHelper

  attr_reader :line_item

  delegate :name, :quantity, :unit_price, :created_at, to: :line_item

  def initialize(line_item)
    @line_item = line_item
  end

  def formatted_unit_price
    humanized_money_with_cents_and_symbol(@line_item.unit_price)
  end

  def formatted_total_price
    humanized_money_with_cents_and_symbol(@line_item.total_price)
  end

  def net_price
    @line_item.net_price.to_s
  end

  def formatted_net_price
    humanized_money_with_cents_and_symbol(@line_item.net_price)
  end

  def gross_price
    @line_item.gross_price.to_s
  end

  def formatted_gross_price
    humanized_money_with_cents_and_symbol(@line_item.gross_price)
  end

  def total_price
    @line_item.total_price.to_s
  end

  def formatted_total_price
    humanized_money_with_cents_and_symbol(@line_item.total_price)
  end

  def class_name
    @line_item.class.name.demodulize
  end

  def is_service_fee?
    @line_item.is_service_fee?
  end

end

