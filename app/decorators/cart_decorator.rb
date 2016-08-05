class CartDecorator
  include MoneyRails::ActionViewExtension
  include ActionView::Helpers::TagHelper

  def initialize(user, order=nil, step=nil)
    @user = user
    @step = step
    @order = order
  end

  def cart_orders
    @cart_orders ||= if @order
      [@order]
    else
      @user.cart_orders.decorate
    end
  end

  alias orders cart_orders

  def items_count
    cart_orders.size
  end

  def line_items_count
    cart_orders.map(&:transactable_line_items).flatten.size
  end

  def total
    case @step
    when :payment then cart_orders.map(&:total_amount).sum
    when :delivery then cart_orders.map(&:total).sum
    else
      cart_orders.map(&:subtotal_amount).sum
    end
  end

  def total_with_fees
    cart_orders.sum(:total)
  end

  def navigation
    "(#{line_items_count}) #{total_display}"
  end

  def total_display
    "#{orders.first.currency_object.try(:symbol)} #{content_tag(:span, humanized_money(total.to_money), data: {"cart-total": true})}"
  end

  def empty?
    items_count < 1
  end

  def different_companies?
    orders.count > 1
  end
end
