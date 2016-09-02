class Dashboard::Company::OrdersReceivedController < Dashboard::Company::BaseController
  before_filter :find_order, except: :index

  def index
    @order_search_service = OrderSearchService.new(order_scope, params)
    render 'dashboard/orders/index'
  end

  def show
    @order = @order.decorate
  end

  def edit
    # Not used for now
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
    @order.complete!
    @order.transactable.finish!
    flash[:success] = t('flash_messages.manage.order.approved')
    redirect_to request.referer.presence || location_after_save
  end

  def archive
    @order.touch(:archived_at)
    flash[:success] = t('flash_messages.dashboard.order.archived')
    redirect_to request.referer.presence || location_after_save
  end

  # TODO this is only used for Purchase but should confirm Reservation and ReservationRequest correctly
  # The idea is to move all host action for all Order types here
  def confirm
    if @order.confirmed?
      flash[:warning] = t('flash_messages.manage.reservations.reservation_already_confirmed')
    elsif @order.unconfirmed?
      if @order.skip_payment_authorization?
        @order.invoke_confirmation!
      else
        @order.charge_and_confirm!
      end

      if @order.confirmed?
        event_tracker.confirmed_a_recurring_booking(@order)
        WorkflowStepJob.perform("WorkflowStep::#{@order.class.workflow_class}Workflow::ManuallyConfirmed".constantize, @order.id)

        track_order_update_profile_informations
        event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
        event_tracker.confirmed_a_booking(@order)
        if @order.reload.paid_until.present? || !@order.instance_of?(RecurringBooking)
          flash[:success] = t('flash_messages.manage.reservations.reservation_confirmed')
        else
          @order.overdue!
          flash[:warning] = t('flash_messages.manage.reservations.reservation_confirmed_but_not_charged')
        end

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
  end

  def rejection_form
    render layout: false
  end


  def reject
    if @order.reject(rejection_reason)
      event_tracker.rejected_a_booking(@order)
      track_order_update_profile_informations
      flash[:deleted] = t('flash_messages.manage.reservations.reservation_rejected')
    else
      flash[:error] = t('flash_messages.manage.reservations.reservation_not_confirmed')
    end

    redirect_to request.referer.presence || dashboard_offers_path
    render_redirect_url_as_json if request.xhr?
  end

  private

  def order_scope
    @order_scope ||=  @company.orders.active
  end

  def track_order_update_profile_informations
    event_tracker.updated_profile_information(@order.owner)
    event_tracker.updated_profile_information(@order.host)
  end

  def location_after_save
    if @order.owner.id == current_user.id
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
end
