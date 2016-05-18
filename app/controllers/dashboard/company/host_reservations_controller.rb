class Dashboard::Company::HostReservationsController < Dashboard::Company::BaseController
  before_filter :find_reservation, except: [:index]
  before_filter :check_if_pending_guest_confirmation, only: [:complete_reservation, :submit_complete_reservation]
  before_filter :redirect_to_account_if_verification_required

  def index
    @guest_list = Controller::GuestList.new(current_user).filter(params[:state])
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
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
        event_tracker.confirmed_a_booking(@reservation)
        track_reservation_update_profile_informations
        event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
        flash[:success] = t('flash_messages.manage.reservations.reservation_confirmed')
      else
        flash[:error] = [
          t('flash_messages.manage.reservations.reservation_not_confirmed'),
          *@reservation.errors.full_messages, *@reservation.payment.errors.full_messages
        ].join("\n")
      end
    else
      if @reservation.expired?
        flash[:error] = t('dashboard.host_reservations.reservation_is_expired')
      end
    end

    redirect_to dashboard_company_host_reservations_url
  end

  def rejection_form
    render layout: false
  end

  def reject
    if @reservation.reject(rejection_reason)
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::Rejected, @reservation.id)
      event_tracker.rejected_a_booking(@reservation)
      track_reservation_update_profile_informations
      flash[:deleted] = t('flash_messages.manage.reservations.reservation_rejected')
    else
      flash[:error] = t('flash_messages.manage.reservations.reservation_not_confirmed')
    end

    redirect_to dashboard_company_host_reservations_url
    render_redirect_url_as_json if request.xhr?
  end

  def request_payment
    WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::PaymentRequest, @reservation.id)
    flash[:success] = t('flash_messages.manage.reservations.payment_requested')
    redirect_to dashboard_company_host_reservations_url
  end

  def host_cancel
    if @reservation.host_cancel
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::HostCancelled, @reservation.id)
      event_tracker.cancelled_a_booking(@reservation, { actor: 'host' })
      track_reservation_update_profile_informations
      flash[:deleted] = t('flash_messages.manage.reservations.reservation_cancelled')
    else
      flash[:error] = t('flash_messages.manage.reservations.reservation_not_confirmed')
    end

    redirect_to dashboard_company_host_reservations_url
  end

  def mark_as_paid
    if @reservation.manual_payment? && !@reservation.paid?
      @reservation.payment.mark_as_paid!
      flash[:deleted] = t('flash_messages.manage.reservations.payment_confirmed')
    else
      flash[:error] = t('flash_messages.manage.reservations.payment_failed')
    end

    redirect_to dashboard_company_host_reservations_url
  end

  def complete_reservation
    @reservation = @reservation.decorate
    @reservation_form = CompleteReservationForm.new(@reservation)
  end

  def submit_complete_reservation
    @reservation = @reservation.decorate
    @reservation_form = CompleteReservationForm.new(@reservation)
    if @reservation_form.validate(params[:reservation]) && @reservation_form.save
      @reservation.force_recalculate_fees = true
      @reservation.calculate_prices
      @reservation.save!
      @reservation.payment.update_attributes({
        subtotal_amount_cents: @reservation.subtotal_amount.cents,
        service_fee_amount_guest_cents: @reservation.service_fee_amount_guest.cents,
        service_fee_amount_host_cents: @reservation.service_fee_amount_host.cents,
        service_additional_charges_cents: @reservation.service_additional_charges.cents,
        host_additional_charges_cents: @reservation.host_additional_charges.cents
      })
      if @reservation.payment.authorize
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::HostSubmittedCheckout, @reservation.id)
        PaymentConfirmationExpiryJob.perform_later(@reservation.pending_guest_confirmation + @reservation.listing.hours_for_guest_to_confirm_payment.hours, @reservation.id) if @reservation.listing.hours_for_guest_to_confirm_payment.to_i > 0
      else
        flash[:warning] = t('flash_messages.dashboard.complete_reservation.failed_to_authorize_credit_card')
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::HostSubmittedCheckoutButAuthorizationFailed, @reservation.id)
      end
      redirect_to action: :reservation_completed
    else
      @reservation_form.sync
      flash.now[:error] = t('flash_messages.dashboard.complete_reservation.unable_to_save')
      render :complete_reservation
    end
  end

  def reservation_completed; end

  private

  def find_reservation
    @reservation = @company.reservations.includes(:owner).find(params[:id])
  end

  def rejection_reason
    params[:reservation][:rejection_reason] if params[:reservation] and params[:reservation][:rejection_reason]
  end

  def track_reservation_update_profile_informations
    event_tracker.updated_profile_information(@reservation.owner)
    event_tracker.updated_profile_information(@reservation.host)
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

