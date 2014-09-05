class Locations::ListingsController < ApplicationController
  before_filter :find_listing, only: [:show]
  before_filter :find_location, only: [:show]
  before_filter :redirect_to_location_if_show_page_disabled
  before_filter :redirect_if_listing_inactive, only: [:show]

  def show
    restore_initial_bookings_from_stored_reservation
    @listing.track_impression(request.remote_ip)
    event_tracker.viewed_a_listing(@listing, { logged_in: user_signed_in? })
  end

  protected

  def find_listing
    @listing = Transactable.find(params[:id])
  end

  def find_location
    @location = Location.find(@listing.location_id)
  end

  def redirect_to_location_if_show_page_disabled
    unless TransactableType.pluck(:show_page_enabled).first
      redirect_to location_path(@location, @listing), :status => :moved_permanently
    end
  end

  def redirect_if_listing_inactive
    if @listing.deleted? || @listing.draft?
      flash[:warning] = t('flash_messages.listings.listing_inactive', address: @listing.address)
      redirect_to location_path(@listing.location)
    elsif @listing.disabled? && current_user_cannot_manage_listing?
      flash[:warning] = t('flash_messages.listings.listing_disabled')
      redirect_to location_path(@listing.location)
    end
  end

  def current_user_cannot_manage_listing?
    !current_user_can_manage_listing?
  end

  def current_user_can_manage_listing?
    user_signed_in? && current_user.can_manage_listing?(@listing)
  end
end
