class Dashboard::UserRecurringBookingsController < Dashboard::BaseController
  skip_before_filter :redirect_unless_registration_completed

  before_filter :only => [:user_cancel] do |controller|
    unless allowed_events.include?(controller.action_name)
      flash[:error] = t('flash_messages.reservations.invalid_operation')
      redirect_to redirection_path
    end
  end

  def user_cancel
    if recurring_booking.user_cancel
      WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::GuestCancelled, recurring_booking.id)
      event_tracker.cancelled_a_recurring_booking(recurring_booking, { actor: 'guest' })
      event_tracker.updated_profile_information(recurring_booking.owner)
      event_tracker.updated_profile_information(recurring_booking.host)
      flash[:deleted] = t('flash_messages.reservations.reservation_cancelled')
    else
      flash[:error] = t('flash_messages.reservations.reservation_not_confirmed')
    end
    redirect_to redirection_path
  end

  def export
    respond_to do |format|
      format.ics do
        render :text => ReservationIcsBuilder.new(recurring_booking, current_user).to_s
      end
    end
  end

  def show
    redirect_to upcoming_dashboard_user_recurring_booking_path(params[:id])
  end

  def upcoming
    @recurring_booking = current_user.recurring_bookings.find(params[:id]).decorate
    @reservations = @recurring_booking.reservations.not_archived.to_a.sort_by(&:date)
    render :show
  end

  def archived
    @recurring_booking = current_user.recurring_bookings.find(params[:id]).decorate
    @reservations = @recurring_booking.reservations.archived.to_a.sort_by(&:date)
    render :show
  end

  protected

  def recurring_booking
    begin
      @recurring_booking ||= current_user.recurring_bookings.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise Reservation::NotFound
    end
  end

  def allowed_events
    ['user_cancel']
  end

  def current_event
    params[:event].downcase.to_sym
  end

  def redirection_path
    if @recurring_booking.owner.id == current_user.id
      dashboard_user_reservations_path
    else
      dashboard_host_reservations_path
    end
  end

end
