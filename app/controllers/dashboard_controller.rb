class DashboardController < ApplicationController
  before_filter :authenticate_user!
  before_filter :force_scope_to_instance
  before_filter :find_company, :only => [:analytics, :transfers]
  before_filter :redirect_if_no_company, :only => [:analytics, :transfers]

  def show
    if current_user.reservations.visible.any?
      redirect_to bookings_dashboard_url
    elsif current_user.reservations.upcoming.any?
      redirect_to manage_guests_dashboard_url
    else
      redirect_to edit_user_registration_url
    end
  end

  def manage_guests
    if current_user.companies.any?
      @locations  = current_user.companies.first.locations
    else
      @locations = []
    end
    @guest_list = Controller::GuestList.new(current_user).filter(params[:state])
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
  end

  def listings
    @listings = current_user.companies.first.listings.all
  end

  def guest_rating
    @reservation = current_user.listing_reservations.find(params[:id])
    existing_guest_rating = GuestRating.where(reservation_id: @reservation.id,
                                              author_id: current_user.id)

    if params[:track_email_event]
      event_tracker.track_event_within_email(current_user, request)
      params[:track_email_event] = nil
    end

    if existing_guest_rating.blank?
      manage_guests
      render :manage_guests
    else
      flash[:notice] = t('flash_messages.guest_rating.already_exists')
      redirect_to root_path
    end
  end

  private

  def find_company
    @company = current_user.companies.first
  end

  def redirect_if_no_company
    unless @company && @company.id
      flash[:warning] = t('flash_messages.dashboard.add_your_company')
      redirect_to new_space_wizard_url
    end
  end
end
