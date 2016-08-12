class Dashboard::OrderItemsController < Dashboard::Company::BaseController

  before_filter :find_order

  def index
    redirect_to new_dashboard_order_order_item_path(@order)
  end

  def new
    @order_items = @order.recurring_booking_periods.all
    @order_item = @order.recurring_booking_periods.new
    @order_item.transactable_line_items.build
  end

  def create
    @order_item = @order.recurring_booking_periods.new(order_item_params)
    @order_item.transactable_line_items.build unless @order_item.transactable_line_items.any?
    @order_item.set_service_fees

    if @order_item.save
      redirect_to new_dashboard_order_order_item_path(@order)
    else
      render :new
    end
  end

  private

  def order_item_params
    params.require(:recurring_booking_period).permit(secured_params.order_item)
  end

  def find_order
    @order = current_user.orders.find(params[:order_id])
  end
end
