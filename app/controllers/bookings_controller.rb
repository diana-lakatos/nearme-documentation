class BookingsController < ApplicationController
  before_filter :require_user, :except => [:new]

  def index
    @bookings = current_user.bookings
  end
  
  def destroy
    @booking = current_user.bookings.find(params[:id])
  end
end