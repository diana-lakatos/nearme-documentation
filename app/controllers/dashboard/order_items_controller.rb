class Dashboard::OrderItemsController < Dashboard::Company::BaseController

  before_filter :find_order
  before_filter :check_owner, only: [:approve, :reject]

  def index
    @transactables = (current_user.created_listings.without_state(:pending) + current_user.orders.where.not(confirmed_at: nil).map(&:transactable)).uniq
    @for_transactable = @transactables.find{ |t| t.id.to_s == params[:transactable_id] } if params[:transactable_id].present?
  end

  def show
    @order_item = @order.recurring_booking_periods.find(params[:id])
  end

  def new
    @order_items = @order.recurring_booking_periods.all
    @order_item = @order.recurring_booking_periods.new
    @order_item.transactable_line_items.build
  end

  def edit
    @order_item = @order.recurring_booking_periods.find(params[:id])
  end

  def create
    @order_item = @order.recurring_booking_periods.new(order_item_params)
    @order_item.transactable_line_items.build unless @order_item.transactable_line_items.any?
    @order_item.set_service_fees

    if @order_item.save
      redirect_to dashboard_order_order_items_path(@order, transactable_id: @order.transactable.id)
    else
      render :new
    end
  end

  def update
    @order_item = @order.recurring_booking_periods.find(params[:id])
    if @order_item.update(order_item_params)
      flash[:notice] = t('flash_messages.dashboard.order_items.updated')
      redirect_to dashboard_order_order_item_path(@order, @order_item)
    else
      render :new
    end
  end

  def approve
    @order_item = @order.recurring_booking_periods.find(params[:id])
    @order_item.generate_payment!
    flash[:notice] = t('flash_messages.dashboard.order_items.approved')
    redirect_to dashboard_order_order_items_path(@order, transactable_id: @order.transactable.id)
  end

  def reject

  end

  private

  def order_item_params
    params.require(:recurring_booking_period).permit(secured_params.order_item)
  end

  def find_order
    @order = Order.where("creator_id = :user_id OR user_id = :user_id", user_id: current_user.id).find(params[:order_id]) if params[:order_id]
  end

  def check_owner
    if @order.creator != current_user
      flash[:error] = t('flash_messages.authorizations.not_authorized')
      redirect_to dashboard_path(@order, transactable_id: @order.transactable.id)
    end
  end
end
