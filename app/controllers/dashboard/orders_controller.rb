# frozen_string_literal: true
class Dashboard::OrdersController < Dashboard::BaseController
  before_action :find_order, except: [:index, :new]
  before_action :find_transactable, only: :new
  before_action :redirect_to_index_if_not_editable, only: [:edit, :update]
  before_action :ensure_merchant_account_exists, only: [:new, :create]

  def index
    @rating_systems = reviews_service.get_rating_systems
    @order_search_service = OrderSearchService.new(order_scope, params)
  end

  def enquirer_cancel
    if @order.enquirer_cancelable?
      if @order.user_cancel
        # we want to make generic workflows probably. Maybe even per TT [ many to many ]
        WorkflowStepJob.perform("WorkflowStep::#{@order.class.workflow_class}Workflow::EnquirerCancelled".constantize, @order.id)
        flash[:success] = t('flash_messages.reservations.reservation_cancelled')
      else
        flash[:error] = t('flash_messages.reservations.reservation_not_confirmed')
      end
    else
      flash[:error] = t('flash_messages.reservations.reservation_not_cancellable')
    end
    @order = @order.decorate
    redirect_to request.referer.presence || dashboard_orders_path
  end

  def approve
    if @order.unconfirmed?
      @order.update_attribute(:pending_guest_confirmation, nil)
      @order.touch(:enquirer_confirmed_at)

      @order.invoke_confirmation! do
        if @order.shipping_line_items.count > 0
          @order.recalculate_fees!
          @order.reload
          @order.update_payment_attributes
        end
        @order.payment.authorize unless @order.payment.authorized?
        @order.payment.capture!
      end

      if @order.confirmed? && @order.payment.paid?
        flash[:notice] = t('flash_messages.payments.successful_approval')
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::EnquirerApprovedPayment, @order.id)
      else
        @order.touch(:pending_guest_confirmation)
        @order.update_attribute(:enquirer_confirmed_at, nil)
        @order.payment.void!
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::EnquirerApprovedPaymentButCaptureFailed, @order.id)
        flash[:warning] = t('flash_messages.payments.failed_to_approve')
      end
    end
    redirect_to dashboard_orders_path
  end

  def show
    @order = @order.decorate
  end

  def new
    @order = @transactable_pricing.order_class.new(user: current_user)
    @order.add_line_item!(params)
    build_payment_documents
    @update_path = dashboard_order_path(@order)
    render template: 'checkout/show'
  end

  def edit
    @update_path = dashboard_order_path(@order)
    render template: 'checkout/show'
  end

  def update
    @order.checkout_update = true
    if @order.update_attributes(order_params)
      if @order.payment && @order.payment.express_checkout_payment? && @order.payment.express_checkout_redirect_url
        redirect_to @order.payment.express_checkout_redirect_url
        return
      end

      flash[:notice] = '' unless @order.inactive?
      flash[:error] = @order.errors.full_messages.join(',<br />')

      card_message = @order.payment.try(:credit_card_payment?) ? t('flash_messages.reservations.credit_card_will_be_charged') : ''
      flash[:notice] = t('flash_messages.reservations.reservation_made', message: card_message)
      redirect_to dashboard_company_transactable_type_transactables_path(@order.transactable.transactable_type)
    else
      @update_path = dashboard_order_path(@order)
      flash[:error] = @order.errors.full_messages.join(',<br />')
      render template: 'checkout/show'
    end
  end

  def success
    render action: :show
  end

  private

  def ensure_merchant_account_exists
    unless @company.merchant_accounts.any?(&:verified?)
      flash[:notice] = t('flash_messages.dashboard.order.valid_merchant_account_required')
      redirect_to edit_dashboard_company_payouts_path(redirect_url: new_dashboard_order_path(transactable_id: @transactable.id))
   end
  end

  def find_transactable
    if @transactable = current_user.approved_transactables_collaborated.find_by(id: params[:transactable_id])
      params[:transactable_pricing_id] ||= @transactable.action_type.pricings.first.id
      @transactable_pricing = @transactable.action_type.pricings.find(params[:transactable_pricing_id])
    else
      flash[:error] = I18n.t('dashboard.orders.not_collaborator')
      redirect_to dashboard_company_transactable_type_transactables_path(TransactableType.first)
    end
  end

  def build_payment_documents
    @order.transactables.each do |transactable|
      if transactable.document_requirements.blank? &&
         PlatformContext.current.instance.force_file_upload?
        transactable.document_requirements.create(label: I18n.t('upload_documents.file.default.label'),
                                                  description: I18n.t('upload_documents.file.default.description'))
      end

      requirement_ids = @order.payment_documents.map do |pd|
        pd.payment_document_info.document_requirement_id
      end

      if transactable.upload_obligation.blank? &&
         PlatformContext.current.instance.documents_upload_enabled?
        transactable.create_upload_obligation(level: UploadObligation.default_level)
      end

      transactable.document_requirements.each do |req|
        next if req.item.upload_obligation.not_required? || requirement_ids.include?(req.id)
        @order.payment_documents.build(
          attachable: @order,
          user: @user,
          payment_document_info_attributes: {
            document_requirement: req
          }
        )
      end
    end
  end

  def order_scope
    @order_scope ||= current_user.orders.active
  end

  def find_order
    @order = current_user.orders.find(params[:id])
  end

  def reviews_service
    @reviews_service ||= ReviewsService.new(current_user, params)
  end

  def redirect_to_index_if_not_editable
    redirect_to request.referer.presence || dashboard_orders_path unless @order.enquirer_editable?
  end

  def order_params
    params.require(:order).permit(secured_params.order(@order.transactable.transactable_type.reservation_type))
  end
end
