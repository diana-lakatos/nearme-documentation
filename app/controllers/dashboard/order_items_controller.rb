class Dashboard::OrderItemsController < Dashboard::Company::BaseController

  before_filter :find_order
  before_filter :find_order_item, except: [:index, :new, :create]
  before_filter :can_edit?, only: [:edit, :update]

  def index
    @transactables = (current_user.created_listings.without_state(:pending) + current_user.orders.where.not(confirmed_at: nil).map(&:transactable)).uniq
    @for_transactable = @transactables.find{ |t| t.id.to_s == params[:transactable_id] } if params[:transactable_id].present?
  end

  def show
  end

  def new
    @order_items = @order.recurring_booking_periods.all
    @order_item = @order.recurring_booking_periods.new
  end

  def edit
  end

  def create
    @order_item = @order.recurring_booking_periods.new(order_item_params)
    if @order_item.transactable_line_items.blank? && @order_item.additional_line_items.blank?
      @order_item.errors.add(:line_items, :blank)
    else
      @order_item.set_service_fees

      if @order_item.save
        redirect_to dashboard_order_order_items_path(@order, transactable_id: @order.transactable.id) and return
      end
    end

    render :new
  end

  def update
    if @order_item.update(order_item_params)
      @order_item.recalculate_fees!
      flash[:notice] = t('flash_messages.dashboard.order_items.updated')
      redirect_to dashboard_order_order_item_path(@order, @order_item)
    else
      render :new
    end
  end

  private

  def can_edit?
    if @order_item.paid? || @order_item.approved?
      flash[:error] = t('flash_messages.dashboard.order_items.can_not_edit_accepted_order_item')
      redirect_to dashboard_order_order_items_path(@order, transactable_id: @order.transactable.id)
      return
    end
  end

  def order_item_params
    params.require(:recurring_booking_period).permit(secured_params.order_item)
  end

  def find_order
    @order = current_user.orders.find(params[:order_id]) if params[:order_id]
  end

  def find_order_item
    @order_item = @order.recurring_booking_periods.find(params[:id])
  end
end
