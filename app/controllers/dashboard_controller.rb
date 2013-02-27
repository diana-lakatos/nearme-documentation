class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def show
    if current_user.reservations.visible.any?
      redirect_to bookings_dashboard_url
    elsif current_user.listing_reservations.upcoming.any?
      redirect_to manage_guests_dashboard_url
    else
      redirect_to edit_user_registration_url
    end
  end

  def index
    if current_user.companies.blank?
      redirect_to new_space_wizard_url
    end
  end

  #routes
  def manage_guests
    @locations  = current_user.locations.all
    @guest_list ||= current_user.listing_reservations.upcoming
  end

  def locations
    @locations ||= current_user.locations.all
  end

  def listings
    @listings = current_user.listings.all
  end

  def bookings
    @your_reservations = current_user.reservations.visible.to_a.sort_by(&:date)
  end

end
