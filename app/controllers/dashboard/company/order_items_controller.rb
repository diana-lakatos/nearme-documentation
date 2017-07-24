class Dashboard::Company::OrderItemsController < Dashboard::Company::BaseController
  before_filter :find_order
  before_filter :find_order_item, except: [:index, :new, :create]
  before_filter :check_owner, only: [:approve, :reject]
  before_filter :verfiy_merchant_account, only: [:approve]

  def index
    @transactables = current_user.created_listings.without_state(:pending).order('created_at DESC')
    @for_transactable = @transactables.find { |t| t.id.to_s == params[:transactable_id] } if params[:transactable_id].present?
  end

  def show
  end

  def approve
    if @order_item.total_amount.cents != params[:total].to_i
      flash[:error] = t('flash_messages.dashboard.order_items.recently_edited')
    else
      if @order_item.charge_and_approve
        flash[:notice] = t('flash_messages.dashboard.order_items.approved')
      else
        flash[:error] = t('flash_messages.dashboard.order_items.approve_failed')
        flash[:error] << ' ' +  @order_item.payment.errors.full_messages.join(', ')
        flash[:error] << ' ' +  @order_item.errors.full_messages.join(', ')
      end
    end

    redirect_to dashboard_company_order_order_items_path(@order, transactable_id: @order.transactable.id)
  end

  def rejection_form
  end

  def reject
    if @order_item.update_attribute(:rejection_reason, order_item_params[:rejection_reason])
      if @order_item.reject!
        flash[:notice] = t('flash_messages.dashboard.order_items.rejected')
      else
        flash[:error] = t('flash_messages.dashboard.order_items.reject_failed')
      end
    end
    redirect_to dashboard_company_order_order_items_path(@order, transactable_id: @order.transactable.id)
  end

  private

  def order_item_params
    params.require(:recurring_booking_period).permit(secured_params.order_item)
  end

  def find_order
    @order = @company.orders.find_by_id(params[:order_id])
  end

  def find_order_item
    @order_item = @order.recurring_booking_periods.find(params[:id])
  end

  def check_owner
    if @order.creator != current_user
      flash[:error] = t('flash_messages.authorizations.not_authorized')
      redirect_to dashboard_path(@order, transactable_id: @order.transactable.id)
    end
  end

  def verfiy_merchant_account
    unless @order_item.user.default_company.merchant_accounts.verified.any?
      flash[:error] = t('flash_messages.dashboard.order_items.approve_failed')
      redirect_to dashboard_company_order_order_items_path(@order, transactable_id: @order.transactable.id)
    end
  end
end
