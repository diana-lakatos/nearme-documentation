module Workplaces
  class BookingsController < ::BookingsController
    before_filter :find_workplace
    before_filter :require_creator, :except => [:new, :create]
    before_filter :find_date, :only => [:new, :create]
    before_filter :ensure_date_valid, :only => [:new, :create]
    before_filter :ensure_desk_available, :only => [:new, :create]

    def index
    end

    def new
      session[:user_return_to] = current_user ? nil : request.fullpath
      @booking = @bookings.build(:date => params[:date])
      respond_to do |wants|
        wants.js { render :layout => false }
        wants.html { render }
      end
    end

    def create
      session[:user_return_to] = nil
      @booking = @bookings.build(params[:booking].merge(:user_id => current_user.id))
      if @booking.save
        flash[:notice] = "Booking Successful."
        begin
          redirect_to request.xhr? ? :back : @workplace
        rescue
          redirect_to @workplace
        end
      else
        render :new
      end
    end

    protected

    def ensure_date_valid
      if @date < Date.today
        flash[:notice] = "Who do you think you are, Marty McFly? You can't book a desk in the past!"
        redirect_to @workplace and return
      end
    end

    def ensure_desk_available
      unless @workplace.desks_available?(@date)
        flash[:notice] = "There are no more desks left for that date. Sorry."
        redirect_to @workplace and return
      end
    end

    def require_creator
      unless @workplace.created_by?(current_user)
        flash[:error] = "You didn't create this workplace, so you can't do stuff to it."
        redirect_to @workplace
      end
    end

    def find_date
      @date = Date.parse(params[:date] || params[:booking][:date])
    rescue
      @date = Date.today
    end

    def find_workplace
      @workplace ||= Workplace.find(params[:workplace_id])
    end

    def fetch_bookings
      @bookings = find_workplace.bookings
    end

    def allowed_events
      events = [:owner_cancel]
      events += [:confirm, :reject] if find_workplace.confirm_bookings?
      events
    end
  end
end
