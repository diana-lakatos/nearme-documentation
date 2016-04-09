class Dashboard::UserReservations::PaymentsController <  Dashboard::BaseController
  before_filter :find_reservation
  before_filter :find_payment
  before_filter :check_if_actionable, only: [:approve, :rejection_form, :reject]
  before_filter :check_if_editable, only: [:edit, :update]

  def edit
  end

  def update
    if @payment.update_attributes(payment_params)
      if @payment.authorize
        flash[:success] = t('flash_messages.payments.updated')
      else
        flash[:error] = t('flash_messages.payments.authorization_failed_anyway')
      end
      redirect_to dashboard_user_reservations_path
      render_redirect_url_as_json
    else
      render :edit
    end
  end

  def approve
    @reservation.update_attribute(:pending_guest_confirmation, nil)
    if @reservation.payment.capture!
      flash[:notice] = t('flash_messages.payments.successful_approval')
      @reservation.mark_as_archived!
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::GuestApprovedPayment, @reservation.id)
    else
      @reservation.payment.void!
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::GuestApprovedPaymentButCaptureFailed, @reservation.id)
      flash[:warning] = t('flash_messages.payments.failed_to_approve')
    end
    redirect_to dashboard_user_reservations_path
  end

  def rejection_form
  end

  def reject
    attributes = {
      pending_guest_confirmation: nil
    }
    attributes.merge!(rejection_reason: params[:reservation][:rejection_reason]) if params[:reservation]
    if @reservation.update_attributes(attributes)
      @reservation.payment.void!
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::GuestDeclinedPayment, @reservation.id)
      flash[:notice] = t('flash_messages.payments.successful_rejection')
    end
    redirect_to dashboard_user_reservations_path
  end

  private

  def find_reservation
    @reservation = current_user.reservations.find(params[:user_reservation_id])
  end

  def find_payment
    @payment = @reservation.payment
  end

  def check_if_actionable
    unless @reservation.can_approve_or_decline_checkout?
      flash[:error] = t('flash_messages.payments.cannot_take_action')
      redirect_to dashboard_user_reservations_path
    end
  end

  def check_if_editable
    unless @reservation.has_to_update_credit_card?
      if request.xhr?
        render text: t('flash_messages.payments.cannot_edit')
      else
        flash[:error] = t('flash_messages.payments.cannot_edit')
        redirect_to dashboard_user_reservations_path
      end
    end
  end

  def payment_params
    params.require(:payment).permit(secured_params.payment)
  end
end
