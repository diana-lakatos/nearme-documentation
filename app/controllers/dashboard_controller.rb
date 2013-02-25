class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def show
    if current_user.reservations.visible.any?
      redirect_to bookings_dashboard_url
    elsif current_user.listing_reservations.upcoming.any?
      redirect_to reservations_dashboard_url
    else
      redirect_to edit_user_registration_url
    end
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

  def index
    if current_user.companies.blank?
      redirect_to new_space_wizard_url
    end
  end
end
