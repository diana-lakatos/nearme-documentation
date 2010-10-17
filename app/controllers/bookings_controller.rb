class BookingsController < ApplicationController
  before_filter :require_user, :except => [:new]

  def index
    @bookings = current_user.bookings
  end
  
  def destroy
    @booking = current_user.bookings.find(params[:id])
    @booking.cancel
    flash[:notice] = "Your booking has been cancelled"
    redirect_to :back
  end
end