class ReservationsController < ApplicationController
  before_filter :authenticate_user!, :except => :new
  before_filter :fetch_reservations
  before_filter :fetch_reservation, :only => [:user_cancel]
  before_filter :fetch_current_user_reservation, :only => [:export, :host_rating]

  before_filter :only => [:user_cancel] do |controller|
    unless allowed_events.include?(controller.action_name)
      flash[:error] = t('flash_messages.reservations.invalid_operation')
      redirect_to redirection_path
    end
  end

  def user_cancel
    if @reservation.user_cancel
      ReservationMailer.enqueue.notify_host_of_cancellation_by_guest(platform_context, @reservation)
      ReservationMailer.enqueue.notify_guest_of_cancellation_by_guest(platform_context, @reservation)
      event_tracker.cancelled_a_booking(@reservation, { actor: 'guest' })
      event_tracker.updated_profile_information(@reservation.owner)
      event_tracker.updated_profile_information(@reservation.host)
      flash[:deleted] = t('flash_messages.reservations.reservation_cancelled')
    else
      flash[:error] = t('flash_messages.reservations.reservation_not_confirmed')
    end
    redirect_to redirection_path
  end

  def index
    redirect_to upcoming_reservations_path
  end

  def export
    respond_to do |format|
      format.ics do
        render :text => ReservationIcsBuilder.new(@reservation, current_user).to_s
      end
    end
  end

  def upcoming
    unless current_user.reservations.empty?
      @reservations = current_user.reservations.not_archived.to_a.sort_by(&:date)
      @reservation = params[:id] ? current_user.reservations.find(params[:id]) : nil
    end

    event_tracker.mailer_view_your_booking_clicked(current_user) if params[:track_email_event]
    render :index
  end

  def archived
    @reservations = current_user.reservations.archived.to_a.sort_by(&:date)
    render :index
  end

  def host_rating
    existing_host_rating = HostRating.where(reservation_id: @reservation.id,
                                            author_id: current_user.id)
    if existing_host_rating.blank?
      upcoming
    else
      flash[:notice] = t('flash_messages.host_rating.already_exists')
      redirect_to root_path
    end
  end

  protected

  def fetch_reservations
    @reservations = current_user.reservations
  end

  def fetch_reservation
    @reservation = @reservations.find(params[:id])
  end

  def fetch_current_user_reservation
    @reservation = current_user.reservations.find(params[:id])
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
