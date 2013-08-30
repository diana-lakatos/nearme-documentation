class ReservationsController < ApplicationController
  before_filter :authenticate_user!, :except => :new
  before_filter :fetch_reservations
  before_filter :fetch_reservation, :only => [:user_cancel]
  before_filter :fetch_current_user_reservation, :only => [:show, :export, :guest_rating, :host_rating]
  before_filter :redirect_if_rating_already_exists, :only => [:guest_rating, :host_rating]

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
      event_tracker.updated_profile_information(@reservation.owner)
      event_tracker.updated_profile_information(@reservation.host)
      flash[:deleted] = "You have cancelled your reservation."
    else
      flash[:error] = "Your reservation could not be confirmed."
    end
    redirect_to redirection_path
  end

  def index
    redirect_to upcoming_reservations_path
  end

  def show
  end

  def export
    respond_to do |format|
      format.ics do
        calendar = RiCal.Calendar do |cal|
          cal.add_x_property 'X-WR-CALNAME', 'Desks Near Me' 
          cal.add_x_property 'X-WR-RELCALID', "#{current_user.id}"
          @reservation.periods.each do |period|
            cal.event do |event|
              event.description = @reservation.listing.description
              event.summary = @reservation.listing.name
              event.uid = "#{@reservation.id}_#{period.date.to_s}"
              hour = period.start_minute/60.floor
              minute = period.start_minute - (hour * 60)
              event.dtstart = period.date.strftime("%Y%m%dT") + "#{"%02d" % hour}#{"%02d" % minute}00"
              hour = period.end_minute/60.floor
              minute = period.end_minute - (hour * 60)
              event.dtend = period.date.strftime("%Y%m%dT") + "#{"%02d" % hour}#{"%02d" % minute}00"
              event.created = @reservation.created_at
              event.last_modified = @reservation.updated_at
              event.location = @reservation.listing.address
              event.url = Rails.application.routes.url_helpers.reservation_url(@reservation)
            end
          end
        end
        
        render :text => calendar.to_s.gsub("\n", "\r\n")
      end
    end
  end

  def upcoming
    @reservations = current_user.reservations.not_archived.to_a.sort_by(&:date)
    if @reservations.empty?
      flash[:warning] = "You haven't made any bookings yet!"
      redirect_to search_path
    else
      @reservation = params[:id] ? current_user.reservations.find(params[:id]) : nil
      render :index
    end
  end

  def archived
    @reservations = current_user.reservations.archived.to_a.sort_by(&:date)
    render :index
  end

  def guest_rating
    render :show
  end

  def host_rating
    render :show
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

  def redirect_if_rating_already_exists
    klass = params[:action].classify.constantize
    if klass.where(reservation_id: @reservation.id, author_id: current_user.id).exists?
      flash[:notice] = "Rating for this booking has already been submitted."
      redirect_to root_path
    end
  end

end
