class Dashboard::Company::HostReservationsController < Dashboard::Company::BaseController
  before_filter :find_reservation, except: [:index]

  def index
    @guest_list = Controller::GuestList.new(current_user).filter(params[:state])
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
  end

  def confirm
    if @reservation.confirmed?
      flash[:warning] = t('flash_messages.manage.reservations.reservation_already_confirmed')
    else
      @reservation.charge_and_confirm!
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
      @reservation.mark_as_paid!
      flash[:deleted] = t('flash_messages.manage.reservations.payment_confirmed')
    else
      flash[:error] = t('flash_messages.manage.reservations.payment_failed')
    end

    redirect_to dashboard_company_host_reservations_url
  end

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

end

