class ReservationsController < ApplicationController
  before_filter :authenticate_user!, :except => :new
  before_filter :fetch_reservations
  before_filter :fetch_reservation, :only => [:confirm, :reject, :owner_cancel, :user_cancel]

  before_filter :only => [:confirm, :reject, :owner_cancel, :user_cancel] do |controller|
    unless allowed_events.include?(controller.action_name)
      flash[:error] = "Not a valid reservation operation."
      redirect_to redirection_path
    end
  end

  def confirm
    @reservation.confirm
    flash[:success] = "You have confirmed the reservation!"
    redirect_to redirection_path
  end

  def reject
    @reservation.reject
    flash[:deleted] = "You have rejected the reservation. Maybe next time!"
    redirect_to redirection_path
  end

  def owner_cancel
    @reservation.owner_cancel
    flash[:deleted] = "You have cancelled this reservation."
    redirect_to redirection_path
  end

  def user_cancel
    @reservation.user_cancel
    flash[:deleted] = "You have cancelled your reservation."
    redirect_to redirection_path
  end

  protected

  def fetch_reservations
    @reservations = current_user.reservations
  end

  def fetch_reservation
    @reservation = @reservations.find(params[:id])
  end

  def allowed_events
    if current_user == @reservation.location.creator
      ['confirm', 'reject', 'owner_cancel']
    elsif current_user = @reservation.owner
      ['user_cancel']
    else
      []
    end
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
