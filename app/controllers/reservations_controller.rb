class ReservationsController < ApplicationController
  before_filter :authenticate_user!, :except => :new
  before_filter :fetch_reservations
  before_filter :fetch_reservation, :only => [:user_cancel]

  before_filter :only => [:user_cancel] do |controller|
    unless allowed_events.include?(controller.action_name)
      flash[:error] = "Not a valid reservation operation."
      redirect_to redirection_path
    end
  end

  def user_cancel
    if @reservation.user_cancel
      ReservationMailer.notify_host_of_cancellation(@reservation).deliver
      event_tracker.cancelled_a_booking(@reservation, { actor: 'guest' })
      flash[:deleted] = "You have cancelled your reservation."
    else
      flash[:error] = "Your reservation could not be confirmed."
    end
    redirect_to redirection_path
  end

  def index
    redirect_to upcoming_reservations_path
  end

  def upcoming
    @reservations = current_user.reservations.not_archived.to_a.sort_by(&:date)
    @reservation = params[:id] ? current_user.reservations.find(params[:id]) : nil
    render :index
  end

  def archived
    @reservations = current_user.reservations.archived.to_a.sort_by(&:date)
    render :index
  end

  protected

  def fetch_reservations
    @reservations = current_user.reservations
  end

  def fetch_reservation
    @reservation = @reservations.find(params[:id])
  end

  def allowed_events
    ['user_cancel']
  end

  def current_event
    params[:event].downcase.to_sym
  end

  def redirection_path
    if @reservation.owner.id == current_user.id
      bookings_dashboard_path
    else
      manage_guests_dashboard_path
    end
  end

end
