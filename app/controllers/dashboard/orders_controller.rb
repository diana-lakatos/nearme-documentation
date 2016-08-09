class Dashboard::OrdersController < Dashboard::BaseController
  before_action :find_order, except: [:index]
  before_action :redirect_to_index_if_not_editable, only: [:edit, :update]

  def index
    @rating_systems = reviews_service.get_rating_systems
    @order_search_service = OrderSearchService.new(order_scope, params)
  end

  def enquirer_cancel
    if @order.enquirer_cancelable?
      if @order.user_cancel
        # we want to make generic workflows probably. Maybe even per TT [ many to many ]
        WorkflowStepJob.perform("WorkflowStep::#{@order.object.class.name}::EnquirerCancelled".constantize, @order.id)
        event_tracker.cancelled_a_booking(@order, { actor: 'guest' })
        event_tracker.updated_profile_information(@order.owner)
        event_tracker.updated_profile_information(@order.host)
        flash[:success] = t('flash_messages.reservations.reservation_cancelled')
      else
        flash[:error] = t('flash_messages.reservations.reservation_not_confirmed')
      end
    else
      flash[:error] = t('flash_messages.reservations.reservation_not_cancellable')
    end
    redirect_to request.referer.presence || dashboard_orders_path
  end

  def show
  end

  def new
    @order = @transactable_pricing.order_class.new(
        currency: @transactable.currency,
        user: current_user
      )
    # @order.user.skip_validations_for = [:seller, :buyer, :default]
    render template: 'checkout/show'
  end

  def create
  end

  def edit
  end

  def update
  end

  def success
    render action: :show
  end

  private

  def order_scope
    @order_scope ||= current_user.orders.active
  end

  def find_order
    @order = current_user.orders.find(params[:id]).decorate
  end

  def reviews_service
    @reviews_service ||= ReviewsService.new(current_user, params)
  end

  def redirect_to_index_if_not_editable
    redirect_to request.referer.presence || dashboard_orders_path unless @order.enquirer_editable?
  end

  def order_params
    params.require(:order).permit(secured_params.order(@transactable.transactable_type.reservation_type))
  end

end
