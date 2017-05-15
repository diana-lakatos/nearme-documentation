# frozen_string_literal: true
class Dashboard::UserReservationsController < Dashboard::BaseController
  before_action only: [:user_cancel] do |controller|
    unless allowed_events.include?(controller.action_name)
      flash[:error] = t('flash_messages.reservations.invalid_operation')
      redirect_to redirection_path
    end
  end

  before_action :reservation, only: [:booking_successful_modal, :booking_failed_modal]

  def user_cancel
    if reservation.cancellable?
      if reservation.user_cancel
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::EnquirerCancelled, reservation.id, as: current_user)
        flash[:success] = t('flash_messages.reservations.reservation_cancelled')
      else
        flash[:error] = t('flash_messages.reservations.reservation_not_confirmed')
      end
    else
      flash[:error] = t('flash_messages.reservations.reservation_not_cancellable')
    end
    redirect_to redirection_path
  end

  def index
    redirect_to upcoming_dashboard_user_reservations_path
  end

  def export
    respond_to do |format|
      format.ics do
        render text: ReservationIcsBuilder.new(reservation, current_user).to_s
      end
    end
  end

  def upcoming
    @reservation  = reservation if params[:id]
    @reservations = reservations.not_archived.to_a.sort_by(&:date)
    @upcoming_count = @reservations.count
    @archived_count = current_user.orders.reservations.archived.count

    render :index
  end

  def archived
    @reservations = reservations.archived.to_a.sort_by(&:date)
    @upcoming_count = current_user.orders.reservations.not_archived.count
    @archived_count = @reservations.count
    render :index
  end

  def booking_successful
    upcoming
  end

  def booking_failed
    upcoming
  end

  def booking_successful_modal
    render template: 'dashboard/user_reservations/booking_successful_modal', formats: [:html], layout: false
  end

  def booking_failed_modal
  end

  def remote_payment
    if reservation.paid?
      redirect_to booking_successful_dashboard_user_reservation_path(reservation)
    else
      setup_payment_gateway
      upcoming
    end
  end

  def remote_payment_modal
    setup_payment_gateway
  end

  def recurring_booking_successful
    @recurring_booking = current_user.recurring_bookings.find(params[:id])
    params[:id] = nil
    upcoming
  end

  def recurring_booking_successful_modal
  end

  protected

  def setup_payment_gateway
    reservation.payment_gateway.set_payment_data(reservation)
  end

  def reservations
    @reservations ||= current_user.orders.reservations
  end

  def recurring_bookings
    @recurring_bookings ||= current_user.recurring_bookings
  end

  def reservation
    @reservation ||= current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise Reservation::NotFound
  end

  def allowed_events
    ['user_cancel']
  end

  def current_event
    params[:event].downcase.to_sym
  end

  def redirection_path
    if @reservation.owner.id == current_user.id
      dashboard_orders_path
    else
      dashboard_company_orders_received_index_path
    end
  end
end
