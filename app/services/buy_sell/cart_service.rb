class BuySell::CartService

  def initialize(user)
    @user = user
  end

  # TODO: Check stock on QTY
  def add_product(product, quantity=1)
    setup_order(product)
    Spree::OrderPopulator.new(@order, @order.currency).populate(product.master.id, quantity)
    @order.restart_checkout_flow
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

      # TODO: Check stock on QTY

      line_item.update_attribute :quantity, item[1]
      update_order(line_item.order)
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
      @order = @user.cart_orders.find_by(company_id: product.company_id) # There must be separate order for each company
      create_order(product.company_id) unless @order
    end
  end

  def create_order(company_id)
    @order = @user.orders.create!(company_id: company_id)
  end

  def update_order(order)
    order.update!
    order.updater.update_item_count
    order.restart_checkout_flow
    order.destroy if order.line_items.count == 0
  end
end
