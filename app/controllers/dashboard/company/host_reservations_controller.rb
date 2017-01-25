class Dashboard::Company::HostReservationsController < Dashboard::Company::BaseController
  before_action :find_reservation, except: [:index]
  before_action :check_if_pending_guest_confirmation, only: [:complete_reservation, :submit_complete_reservation]
  before_action :redirect_to_account_if_verification_required

  def index
    @guest_list = Controller::GuestList.new(current_user).filter(params[:state])
  end

  def confirm
    if @reservation.confirmed?
      flash[:warning] = t('flash_messages.manage.reservations.reservation_already_confirmed')
    # We may end up here if for example the user clicks an old link in an activation email
    elsif @reservation.unconfirmed?
      if @reservation.skip_payment_authorization?
        @reservation.invoke_confirmation!
      else
        @reservation.charge_and_confirm!
      end
      if @reservation.confirmed?
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::ManuallyConfirmed, @reservation.id)
        flash[:success] = t('flash_messages.manage.reservations.reservation_confirmed')
      else
        flash[:error] = [
          t('flash_messages.manage.reservations.reservation_not_confirmed'),
          *@reservation.errors.full_messages, *@reservation.payment.errors.full_messages
        ].join("\n")
      end
    else
      flash[:error] = t('dashboard.host_reservations.reservation_is_expired') if @reservation.expired?
    end

    redirect_to redirection_path
  end

  def rejection_form
    render layout: false
  end

  def reject
    if @reservation.reject(rejection_reason)
      flash[:deleted] = t('flash_messages.manage.reservations.reservation_rejected')
    else
      flash[:error] = t('flash_messages.manage.reservations.reservation_not_confirmed')
    end

    redirect_to redirection_path
    render_redirect_url_as_json if request.xhr?
  end

  def request_payment
    WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::PaymentRequest, @reservation.id)
    flash[:success] = t('flash_messages.manage.reservations.payment_requested')
    redirect_to redirection_path
  end

  def host_cancel
    if @reservation.host_cancel
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::ListerCancelled, @reservation.id)
      flash[:deleted] = t('flash_messages.manage.reservations.reservation_cancelled')
    else
      flash[:error] = t('flash_messages.manage.reservations.reservation_not_confirmed')
    end

    redirect_to redirection_path
  end

  def mark_as_paid
    if @reservation.manual_payment? && !@reservation.paid?
      @reservation.payment.mark_as_paid!
      flash[:deleted] = t('flash_messages.manage.reservations.payment_confirmed')
    else
      flash[:error] = t('flash_messages.manage.reservations.payment_failed')
    end

    redirect_to :back
  end

  def complete_reservation
    @reservation = @reservation.decorate
  end

  def submit_complete_reservation
    @reservation = @reservation.decorate

    # this hack is needed because I do not know any other way of getting access to unit price which was used
    # at a time of making reservation
    unit_price = @reservation.transactable_line_items.detect { |li| li.unit_price > 0 }.unit_price

    @reservation.pending_guest_confirmation = Time.zone.now
    if @reservation.update_attributes(complete_reservation_params)
      @reservation.transactable_line_items.find_each { |li| li.update_attribute(:unit_price, unit_price) }
      @reservation = @reservation.reload
      @reservation.service_fee_line_items.destroy_all
      @reservation.host_fee_line_items.destroy_all
      @reservation.transactable_line_items.find_each do |li|
        li.build_service_fee.try(:save!)
        li.build_host_fee.try(:save!)
      end
      @reservation = @reservation.reload
      @reservation.update_payment_attributes
      @reservation.save!
      if @reservation.payment.authorize!
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::ListerSubmittedCheckout, @reservation.id)
        PaymentConfirmationExpiryJob.perform_later(@reservation.pending_guest_confirmation + @reservation.transactable.hours_for_guest_to_confirm_payment.hours, @reservation.id) if @reservation.transactable.hours_for_guest_to_confirm_payment.to_i > 0
      else
        flash[:warning] = t('flash_messages.dashboard.complete_reservation.failed_to_authorize_credit_card')
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::ListerSubmittedCheckoutButAuthorizationFailed, @reservation.id)
      end
      redirect_to action: :reservation_completed
    else
      flash.now[:error] = t('flash_messages.dashboard.complete_reservation.unable_to_save')
      render :complete_reservation
    end
  end

  def reservation_completed; end

  private

  def redirection_path
    if @reservation.owner.id == current_user.id
      dashboard_orders_path
    else
      dashboard_company_orders_received_index_path
    end
  end

  def complete_reservation_params
    if params[:reservation] && !params[:reservation].blank?
      params.require(:reservation).permit(secured_params.complete_reservation)
    else
      {}
    end
  end

  def find_reservation
    @reservation = @company.orders.reservations.includes(:owner).find(params[:id])
  end

  def rejection_reason
    params[:reservation][:rejection_reason] if params[:reservation] && params[:reservation][:rejection_reason]
  end

  def check_if_pending_guest_confirmation
    unless @reservation.can_complete_checkout?
      flash[:error] = t('flash_messages.dashboard.complete_reservation.pending_confirmation')
      redirect_to dashboard_company_host_reservations_url
    end
  end

  def redirect_to_account_if_verification_required
    if current_user.host_requires_mobile_number_verifications? && !current_user.has_verified_number?
      flash[:warning] = t('flash_messages.manage.reservations.phone_number_verification_needed')
      redirect_to edit_registration_path(current_user)
    end
  end
end
