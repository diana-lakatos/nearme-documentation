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
      @user.cart_orders
    end
  end

  def items_count
    cart_orders.size
  end

  def line_items_count
    cart_orders.map(&:line_items).flatten.size
  end

  def total
    case @step
    when :payment then cart_orders.map(&:total_amount_to_charge).sum
    when :delivery then cart_orders.map(&:total).sum
    else
      cart_orders.map(&:subtotal_amount_to_charge).sum
    end
  end

  def total_with_fees
    cart_orders.sum(:total)
  end

  def navigation
    "(#{line_items_count}) #{total_display}"
  end

  def total_display
    "#{Currency.find_by_iso_code(Spree::Config.currency).try(:symbol)} #{content_tag(:span, humanized_money(total.to_money), data: {"cart-total": true})}"
  end

  def orders
    cart_orders.decorate
  end

  def empty?
    items_count < 1
  end

  def different_companies?
    orders.count > 1
  end
end
