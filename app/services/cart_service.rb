class CartService
  attr_reader :errors

  def initialize(user)
    @user = user
    @errors = []
  end

  # def add_line_item(transactable, options)
  #   @order = @user.cart_orders.first_or_create
  #   @order.add_order_item(transactable, options)
  # end

  def remove_item(item_id)
    item = current_line_items.find(item_id)
    if item.deletable?
      item.destroy
      update_order(item.line_itemable)
    else
      @errors << I18n.t('buy_sell_market.cart.errors.undeletable')
      false
    end
  end

  def update_qty_on_items(items)
    items = items.collect { |item| item.map(&:to_i) }
    items.each do |item|
      line_item = current_line_items.find item[0]

      # QTY is set to 0, lets remove it from cart
      if item[1] < 1
        line_item.destroy
        update_order(line_item.line_itemable)
        next
      end

      if line_item.can_supply?(item[1])
        line_item.update_attribute :quantity, item[1]
        update_order(line_item.line_itemable)
      else
        @errors << I18n.t('buy_sell_market.cart.errors.qty')
        return false
      end
    end
  end

  def current_line_items
    LineItem.where(line_itemable_type: Order::ORDER_TYPES).where(line_itemable_id: @user.cart_orders.map(&:id))
  end

  def empty!
    @user.cart_orders.destroy_all
  end

  private

  def create_order
    @order = @user.orders.create!(email: @user.email)
  end

  def update_order(order)
    # order.updater.update_item_count
    # order.restart_checkout_flow
    if order.transactable_line_items.count < 1
      order.destroy
    else
      order.recalculate_service_fees!
    end
  end
end
