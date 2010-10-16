class BookingsController < ApplicationController
  before_filter :require_user

  def index
    @bookings = current_user.bookings
  end
end