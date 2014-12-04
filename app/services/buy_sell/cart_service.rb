class BuySell::CartService

  attr_reader :errors

  def initialize(user)
    @user = user
    @errors = []
  end

  def add_product(product, quantity=1)
    setup_order(product)
    populator = Spree::OrderPopulator.new(@order, @order.currency)

    unless populator.populate(product.master.id, quantity)
      @errors << populator.errors.full_messages.join('\n')
      return false
    end
  end

  def remove_item(item_id)
    item = Spree::LineItem.find(item_id)
    @order = item.order
    item.destroy
    update_order(@order)
  end

  def update_qty_on_items(items)
    items = items.collect { |item| item.map(&:to_i) }
    items.each do |item|
      line_item = Spree::LineItem.find item[0]

      # QTY is set to 0, lets remove it from cart
      if item[1] < 1
        line_item.destroy
        update_order(line_item.order)
        next
      end

      if line_item.product.master.can_supply?(item[1])
        line_item.update_attribute :quantity, item[1]
        update_order(line_item.order)
      else
        @errors << I18n.t('buy_sell_market.cart.errors.qty')
        return false
      end
    end
  end

  def empty!
    @user.cart_orders.destroy_all
  end

  private

  def setup_order(product)
    if @user.cart_orders.count == 0
      create_order(product.company_id)
    else
      @order = @user.cart_orders.find_by(company_id: product.company_id)
      create_order(product.company_id) unless @order
    end
  end

  def create_order(company_id)
    @order = @user.orders.create!(company_id: company_id,
                                  service_fee_buyer_percent: PlatformContext.current.instance.service_fee_guest_percent,
                                  service_fee_seller_percent: PlatformContext.current.instance.service_fee_host_percent)
  end

  def update_order(order)
    order.update!
    order.updater.update_item_count
    order.restart_checkout_flow
    order.destroy if order.line_items.count == 0
  end
end
