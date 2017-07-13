# frozen_string_literal: true
class Dashboard::Company::OrdersReceivedController < Dashboard::Company::BaseController
  include RejectionReasonErrorHelper

  before_action :find_order, except: :index
  before_action :prepare_order_for_shipping, only: [:show, :confirm, :confirmation_form]
  before_action :validate_deliveries, only: [:cancel]

  rescue_from Deliveries::UnprocessableEntity do
    render partial: 'shared/unprocessable_entity', layout: false
  end

  def index
    @order_search_service = OrderSearchService.new(order_scope, params)
    render 'dashboard/orders/index'
  end

  def show
    @order = @order.decorate
  end

  def edit
    @order = current_user.listing_orders.find(params[:id])

    render template: 'checkout/show', locals: { disabled: true }
  end

  def update
    if @order.update(order_params)
      redirect_to request.referer.presence || location_after_save, notice: t('flash_messages.manage.order.updated')
    else
      flash[:error] = t('flash_messages.manage.order.error_update')
      render :edit
    end
  end

  def destroy
    @order.destroy
    flash[:success] = t('flash_messages.manage.order.deleted')
    redirect_to request.referer.presence || location_after_save
  end

  def cancel
    @order.host_cancel!
    flash[:success] = t('flash_messages.manage.order.canceled')
    redirect_to request.referer.presence || location_after_save
  end

  def complete
    if @order.complete!
      @order.transactable.finish!
      flash[:success] = t('flash_messages.manage.order.approved')
      WorkflowStepJob.perform(WorkflowStep::OrderWorkflow::Completed, @order.id)
    else
      flash[:error] = t('flash_messages.manage.order.can_not_approve')
    end
    redirect_to request.referer.presence || location_after_save
  end

  def archive
    @order.touch(:archived_at)
    flash[:success] = t('flash_messages.dashboard.order.archived')
    redirect_to request.referer.presence || location_after_save
  end

  # TODO: this is only used for Purchase but should confirm Reservation and ReservationRequest correctly
  # The idea is to move all host action for all Order types here
  def confirm
    if params[:order] && order_params.present?
      render(action: :confirmation_form) && return unless @order.update(order_params)
    end

    if @order.confirmed?
      flash[:warning] = t('flash_messages.manage.reservations.reservation_already_confirmed')
    elsif @order.unconfirmed?
      @order.lister_confirmed!
      if @order.skip_payment_authorization?
        @order.invoke_confirmation!
      else
        @order.charge_and_confirm!
      end

      if @order.lister_confirmed_at.present? && @order.action.both_side_confirmation
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::ListerConfirmedWithDoubleConfirmation, @order.id, as: current_user)
      end

      if @order.confirmed?
        WorkflowStepJob.perform("WorkflowStep::#{@order.class.workflow_class}Workflow::ManuallyConfirmed".constantize, @order.id, as: current_user)

        if @order.reload.paid_until.present? || !@order.instance_of?(RecurringBooking)
          flash[:success] = t('flash_messages.manage.reservations.reservation_confirmed')
        else
          @order.overdue!
          flash[:warning] = t('flash_messages.manage.reservations.reservation_confirmed_but_not_charged')
        end

      elsif @order.action.both_side_confirmation
        flash[:success] = t('flash_messages.dashboard.reservations.lender_confirmed_both_side_confirmation')
      else
        flash[:error] = [
          t('flash_messages.manage.reservations.reservation_not_confirmed'),
          *@order.errors.full_messages, *@order.payment.errors.full_messages
        ].join("\n")
      end
    else
      flash[:error] = t('dashboard.host_reservations.reservation_is_expired') if @reservation.expired?
    end
    redirect_to request.referer.presence || location_after_save
    render_redirect_url_as_json if request.xhr?
  end

  def rejection_form
    render layout: false
  end

  def confirmation_form
    render layout: false
  end

  def reject
    if @order.reject(rejection_reason)
      flash[:deleted] = t('flash_messages.manage.reservations.reservation_rejected')
    else
      flash[:error] = rejection_error_messages(@order)
    end

    redirect_to request.referer.presence || dashboard_offers_path
    render_redirect_url_as_json if request.xhr?
  end

  private

  def order_scope
    @order_scope ||= @company.orders.active
  end

  def location_after_save
    if @order.user_id == current_user.id
      dashboard_orders_path
    else
      dashboard_company_orders_received_index_path
    end
  end

  def find_order
    @order = @company.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(secured_params.order(@order.reservation_type))
  end

  def rejection_reason
    params[:order][:rejection_reason] if params[:order] && params[:order][:rejection_reason]
  end

  def prepare_order_for_shipping
    return if @order.confirmed?
    return unless Shippings.enabled?(@order)

    # move detecion into the factory
    # rename factory to builder
    Deliveries::DeliveryFactory.build(
      order: @order,
      shipping_provider:
        Shippings::ShippingProvider.find_by(shipping_provider_name: params[:shipping_provider_name]) || Shippings::ShippingProvider.last,
    )

    Deliveries::BuildShippingLineItems.build(order: @order)
  end

  def validate_deliveries
    return unless Shippings.enabled?(@order)

    Deliveries::SyncOrderDeliveries.new(@order).perform
    redirect_to request.referer.presence, flash: { error: t('flash_messages.manager.reservations.could_not_be_cancelled') } unless @order.cancellable?
  end
end
