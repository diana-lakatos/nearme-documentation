module Workplaces
  class BookingsController < ::BookingsController
    before_filter :find_workplace
    before_filter :require_creator, :only => [:index, :destroy]
    before_filter :find_date, :only => [:new, :create]
    before_filter :ensure_date_valid, :only => [:new, :create]
    before_filter :ensure_desk_available, :only => [:new, :create]
    
    def index
      @bookings = @workplace.bookings
    end

    def new
      session[:user_return_to] = current_user ? nil : request.fullpath
      @booking = @workplace.bookings.build(:date => params[:date])
      render :layout => !request.xhr?
    end

    def create
      session[:user_return_to] = nil
      @booking = @workplace.bookings.build(params[:booking].merge(:user_id => current_user.id))
      if @booking.save
        flash[:notice] = "Booking Successful."
        redirect_to @workplace
      else
        render :new
      end
    end
    
    def destroy
      @booking = @workplace.bookings.find(params[:id])
      @booking.cancel
      flash[:notice] = "Booking Cancelled."
    end

    def reject
      @booking = @workplace.bookings.find(params[:booking_id])
      if @booking.reject
        redirect_to dashboard_path, :notice => "Booking rejected"
      else
        redirect_to dashboard_path, :notice => "There wan an error rejecting the booking"
      end
    end

    def confirm
      @booking = @workplace.bookings.find(params[:booking_id])
      if @booking.confirm
        redirect_to dashboard_path, :notice => "Booking confirmed"
      else
        redirect_to dashboard_path, :notice => "There wan an error confirming the booking"
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
      @workplace = Workplace.find(params[:workplace_id])
    end
  end
end
