class BookingsController < ApplicationController
  before_filter :require_user, :except => [:new]

  def index
    @bookings = current_user.bookings
  end
end