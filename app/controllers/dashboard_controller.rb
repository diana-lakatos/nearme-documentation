class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    @listings = current_user.listings.all
    @your_reservations = current_user.reservations.visible
    @listing_reservations = current_user.listing_reservations.upcoming
  end
end
