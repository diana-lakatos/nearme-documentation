class CartDecorator
  include MoneyRails::ActionViewExtension

  def initialize(user)
    @user = user
  end

  def items_count
    @user.cart_orders.sum(:item_count)
  end

  def line_items_count
    @user.cart_orders.joins(:line_items).count
  end

  def total
    @user.cart_orders.sum(:total)
  end

  def navigation
    "(#{line_items_count}) #{total_display}"
  end

  def total_display
    humanized_money_with_symbol(total.to_money(Spree::Config.currency))
  end

  def orders
    @user.cart_orders.decorate
  end

  def empty?
    items_count < 1
  end

  def different_companies?
    orders.count > 1
  end
end
