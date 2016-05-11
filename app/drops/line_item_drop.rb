class LineItemDrop < BaseDrop
  include CurrencyHelper

  attr_reader :line_item

  delegate :name, :quantity, :unit_price, to: :line_item

  def initialize(line_item)
    @line_item = line_item
  end

  def formatted_unit_price
    humanized_money_with_cents_and_symbol(@line_item.unit_price)
  end

end

