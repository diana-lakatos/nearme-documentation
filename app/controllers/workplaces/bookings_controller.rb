module Workplaces
  class BookingsController < ::BookingsController
    before_filter :find_workplace

    def index
      unless @workplace.created_by?(current_user)
        flash[:error] = "You didn't create this workplace"
        redirect_to @workplace
      else
        @bookings = @workplace.bookings
      end
    end

    def new
      @booking = @workplace.bookings.build(:date => params[:date])
    end

    def create
      @booking = @workplace.bookings.build(params[:booking].merge(:user_id => current_user.id))

      if @booking.save
        flash[:notice] = "Booking successful"
        redirect_to @workplace
      else
        render :new
      end
    end

    protected

    def find_workplace
      @workplace = Workplace.find(params[:workplace_id])
    end
  end
end