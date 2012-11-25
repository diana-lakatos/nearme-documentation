class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def show
  end

  # Legacy dashboard page for managing bookings (user)
  def bookings
    @your_reservations = current_user.reservations.visible
  end

  # Legacy dashboard page for managing reservations (owner)
  def reservations
    @listing_reservations = current_user.listing_reservations.upcoming
  end

  # Legacy dashboard page for managing listings
  def listings
    @listings = current_user.listings.all
  end

end
