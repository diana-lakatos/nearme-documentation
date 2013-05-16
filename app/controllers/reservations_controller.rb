class ReservationsController < ApplicationController
  before_filter :authenticate_user!, :except => :new
  before_filter :fetch_reservations
  before_filter :fetch_reservation, :only => :update
  before_filter :validate_event, :only => :update

  def update
    @reservation.fire_events(current_event)
    flash[allowed_events[current_event]] = "You have #{@reservation.state_name} the reservation"
    redirect_to redirection_path
  end

  protected

  def fetch_reservations
    @reservations = current_user.reservations
  end

  def fetch_reservation
    @reservation = @reservations.find(params[:id])
  end

  def validate_event
    unless allowed_events.key? current_event
      flash['warning red'] = "Not a valid reservation operation"
      redirect_to redirection_path
    end
  end

  def allowed_events
    {:user_cancel => 'delete red'}
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
