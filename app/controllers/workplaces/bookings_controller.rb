module Workplaces
  class BookingsController < ::BookingsController
    before_filter :find_workplace
    before_filter :require_creator, :only => [:index, :destroy]
    
    def index
      @bookings = @workplace.bookings
    end

    def new
      session[:user_return_to] = current_user ? nil : request.fullpath
      @booking = @workplace.bookings.build(:date => params[:date])
      
      if Date.parse(params[:date]) < Date.today
        flash[:notice] = "Who do you think you are, Marty McFly? You can't book a desk in the past!"
        redirect_to @workplace
      end
      
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

    protected
    
    def require_creator
      unless @workplace.created_by?(current_user)
        flash[:error] = "You didn't create this workplace, so you can't do stuff to it."
        redirect_to @workplace
      end
    end

    def find_workplace
      @workplace = Workplace.find(params[:workplace_id])
    end
  end
end