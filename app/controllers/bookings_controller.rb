class BookingsController < ApplicationController
  before_filter :authenticate_user!, :except => :new
  before_filter :fetch_bookings
  before_filter :fetch_booking,      :only   => :update
  before_filter :validate_event,     :only   => :update

  def update
    @booking.fire_events(current_event)
    actioned = "#{current_event}ed".gsub(/^\w+_/,'') # canceled, confirmed, rejected
    flash[:notice] = "You have #{actioned} the booking"
    redirect_to dashboard_path
  end

  protected
    def fetch_bookings
      @bookings = current_user.bookings
    end

    def fetch_booking
      @booking = @bookings.find(params[:id])
    end

    def validate_event
      unless allowed_events.include? current_event
        flash[:error] = "Not a valid booking operation"
        redirect_to dashboard_path
      end
    end

    def allowed_events
      [:user_cancel]
    end

    def current_event
      params[:event].downcase.to_sym
    end
end
