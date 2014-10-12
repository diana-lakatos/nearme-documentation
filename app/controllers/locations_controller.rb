class LocationsController < ApplicationController
  before_filter :authenticate_user!, only: [:ask_a_question]
  before_filter :find_location, only: [:show, :ask_a_question]
  before_filter :find_listing, only: [:show, :ask_a_question]
  before_filter :redirect_to_invidivual_page_if_enabled
  before_filter :redirect_if_location_deleted, only: [:show, :ask_a_question]
  before_filter :redirect_if_location_custom_page, only: [:show, :ask_a_question]
  before_filter :redirect_if_no_active_listings, only: [:show, :ask_a_question]
  before_filter :redirect_if_listing_inactive, only: [:show, :ask_a_question]

  def show
    restore_initial_bookings_from_stored_reservation
    @section_name = 'listings'
    # if listing has been chosen by user, move it at the beginning of array to display it first
    if @listing.present?
      @listings = (@listings - [@listing]).unshift(@listing) if @listing
    else
      @listing ||= @listings.first
    end
    @location.track_impression(request.remote_ip)
    event_tracker.viewed_a_location(@location, { logged_in: user_signed_in? })
  end

  def ask_a_question
    render :show
  end

  def w_hotels
    @location = Location.find_by_custom_page("w_hotels")
    @listing = @location.listings.first
    restore_initial_bookings_from_stored_reservation
  end

  private

  def find_location
    # tmp hack before migrating to Rails 4.1 - with deleted breaks default scope
    @location = Location.find(params[:id])
  end

  def find_listing
    # tmp hack before migrating to Rails 4.1 - with deleted breaks default scope
    @listing = @location.listings.find(params[:listing_id]) if params[:listing_id]
  end

  def redirect_if_location_deleted
    if @location.deleted?
      flash[:warning] = t('flash_messages.locations.listing_removed', address: @location.address)
      redirect_to search_path(:loc => @location.address)
    end
  end

  def redirect_if_location_custom_page
    case @location.custom_page
    when "w_hotels"
      redirect_to(w_hotels_location_url(:restore_reservations => params[:restore_reservations]))
    end
  end

  def redirect_if_no_active_listings
    @listings = @location.listings
    if current_user_can_manage_location?
      flash.now[:warning] = t('flash_messages.locations.browsing_no_listings') if @listings.searchable.empty?
    else
      @listings = @listings.searchable
    end
    if @listings.empty?
      # If location doesn't have any listings, redirects to search page with notice
      flash[:warning] = t('flash_messages.locations.no_listings', bookable_noun_plural: platform_context.decorate.bookable_noun.pluralize)
      redirect_to search_path(:loc => @location.address)
    end
  end

  def redirect_if_listing_inactive
    return true if @listing.nil?
    if @listing.deleted? || @listing.draft?
      flash[:warning] = t('flash_messages.listings.listing_inactive', address: @listing.address)
      redirect_to location_path(@listing.location)
    elsif @listing.disabled?
      if current_user_can_manage_listing?
        flash.now[:warning] = t('flash_messages.listings.listing_disabled_but_admin')
      else
        flash[:warning] = t('flash_messages.listings.listing_disabled')
        redirect_to location_path(@listing.location)
      end
    end
  end

  def current_user_can_manage_location?
    user_signed_in? && (current_user.can_manage_location?(@location) || current_user.instance_admin?)
  end

  def current_user_can_manage_listing?
    user_signed_in? && (current_user.can_manage_listing?(@listing) || current_user.instance_admin?)
  end

  def redirect_to_invidivual_page_if_enabled
    if TransactableType.pluck(:show_page_enabled).first && @listing
      redirect_to location_listing_path(@location, @listing, restore_reservations: params[:restore_reservations])
    end
  end

end
