# frozen_string_literal: true
class Dashboard::UserReservations::PaymentsController < Dashboard::BaseController
  before_action :find_order
  before_action :find_payment
  before_action :check_if_actionable, only: [:approve, :rejection_form, :reject]
  before_action :check_if_editable, only: [:edit, :update]

  def edit
  end

  def update
    if @payment.update_attributes(payment_params)
      if @payment.authorize
        flash[:success] = t('flash_messages.payments.updated')
      else
        flash[:error] = t('flash_messages.payments.authorization_failed_anyway')
      end
      redirect_to dashboard_orders_path
      render_redirect_url_as_json
    else
      render :edit
    end
  end

  def approve
    @order.update_attribute(:pending_guest_confirmation, nil)
    if @order.payment.capture!
      flash[:notice] = t('flash_messages.payments.successful_approval')
      @order.mark_as_archived!
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::EnquirerApprovedPayment, @order.id, as: current_user)
    else
      @order.payment.void!
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::EnquirerApprovedPaymentButCaptureFailed, @order.id, as: current_user)
      flash[:warning] = t('flash_messages.payments.failed_to_approve')
    end
    redirect_to dashboard_orders_path
  end

  def rejection_form
  end

  def reject
    attributes = {
      pending_guest_confirmation: nil
    }
    attributes[:rejection_reason] = params[:delayed_reservation][:rejection_reason] if params[:delayed_reservation]
    if @order.update_attributes(attributes)
      @order.payment.void!
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::EnquirerDeclinedPayment, @order.id, as: current_user)
      flash[:notice] = t('flash_messages.payments.successful_rejection')
    end
    redirect_to dashboard_orders_path
  end

  private

  def find_order
    @order = current_user.orders.find(params[:user_reservation_id])
  end

  def find_payment
    @payment = @order.payment
  end

  def check_if_actionable
    unless @order.can_approve_or_decline_checkout?
      flash[:error] = t('flash_messages.payments.cannot_take_action')
      redirect_to dashboard_orders_path
    end
  end

  def check_if_editable
    unless @order.has_to_update_credit_card?
      if request.xhr?
        render text: t('flash_messages.payments.cannot_edit')
      else
        flash[:error] = t('flash_messages.payments.cannot_edit')
        redirect_to dashboard_orders_path
      end
    end
  end

  def payment_params
    params.require(:payment).permit(secured_params.payment)
  end
end
