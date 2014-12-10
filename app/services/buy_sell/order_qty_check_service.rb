class BuySell::OrderQtyCheckService

  def initialize(order)
    @order = order
    @items_out_of_stock = []
  end

  def check
    @order.line_items.each do |line_item|
      @items_out_of_stock << line_item.name unless line_item.sufficient_stock?
    end

    @items_out_of_stock.count < 1
  end

  def items_out_of_stock
    @items_out_of_stock.join(', ')
  end
end
