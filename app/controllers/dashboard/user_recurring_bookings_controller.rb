class Dashboard::UserRecurringBookingsController < Dashboard::BaseController

  before_filter :only => [:user_cancel] do |controller|
    unless allowed_events.include?(controller.action_name)
      flash[:error] = t('flash_messages.reservations.invalid_operation')
      redirect_to dashboard_user_recurring_bookings_path
    end
  end

  def user_cancel
    if recurring_booking.guest_cancel
      event_tracker.cancelled_a_recurring_booking(recurring_booking, { actor: 'guest' })
      event_tracker.updated_profile_information(recurring_booking.owner)
      event_tracker.updated_profile_information(recurring_booking.host)
      flash[:deleted] = t('flash_messages.reservations.reservation_cancelled')
    else
      flash[:error] = t('flash_messages.reservations.reservation_not_confirmed')
    end
    redirect_to active_dashboard_user_recurring_bookings_path
  end

  def export
    respond_to do |format|
      format.ics do
        render :text => ReservationIcsBuilder.new(recurring_booking, current_user).to_s
      end
    end
  end

  def show
    redirect_to active_dashboard_user_recurring_booking_path(params[:id])
  end

  def index
    redirect_to dashboard_orders_path
  end

  def active
    redirect_to dashboard_orders_path
  end

  def archived
    redirect_to dashboard_orders_path(state: 'archived')
  end

  def booking_successful
    @recurring_booking = current_user.recurring_bookings.find(params[:id])
    params[:id] = nil
    active
  end

  def booking_successful_modal
  end


  protected

  def recurring_booking
    begin
      @recurring_booking ||= current_user.recurring_bookings.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise Reservation::NotFound
    end
  end

  def recurring_bookings
    @recurring_bookings ||= current_user.recurring_bookings
  end

  def allowed_events
    ['user_cancel']
  end

  def current_event
    params[:event].downcase.to_sym
  end

end
