class Spree::LineItemDrop < BaseDrop
  attr_reader :line_item

  def initialize(line_item)
    @line_item = line_item.decorate
  end

  def product_url
    routes.product_path(@line_item.product)
  end

  def reviews_line_item_url
    routes.dashboard_reviews_path
  end

  def owner_first_name
    @line_item.order.user.first_name
  end

  def product_name
    @line_item.product.name
  end
end
