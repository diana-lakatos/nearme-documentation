class Spree::LineItemDrop < BaseDrop
  attr_reader :line_item

  # quantity
  #   quantity to be ordered for this item
  # order
  #   order to which this line item belongs
  # variant
  #   variant of this product that is to be ordered
  delegate :quantity, :order, :variant, :product, to: :line_item

  def initialize(line_item)
    @line_item = line_item.decorate
  end

  # url to the orderable product in the app
  def product_url
    routes.product_path(@line_item.product)
  end

  # url to the reviews section in the user's dashboard
  def reviews_line_item_url
    routes.dashboard_reviews_path
  end

  # the first name of the user ordering this item
  def owner_first_name
    @line_item.order.user.first_name
  end

  # the name of the product that is to be ordered
  def product_name
    @line_item.product.name
  end

  # returns the price to be paid for a single item of this line item
  # in the form of a Money object
  def single_money
    @line_item.single_money.to_s
  end

  # returns the price to be paid for the entire quantity of this line item
  # in the form of a Money object
  def display_amount
    @line_item.display_amount.to_s
  end

  # returns the name of the type of entity selling the products (e.g. seller)
  def lessor
    @line_item.product.product_type.to_liquid.lessor
  end

  # returns the name of the type of entity buying the products (e.g. buyer)
  def lessee
    @line_item.product.product_type.to_liquid.lessee
  end

  # pluralized version of lessor
  def lessors
    @line_item.product.product_type.to_liquid.lessors
  end

  # pluralized version of lessee
  def lessees
    @line_item.product.product_type.to_liquid.lessees
  end

end
