class LocationsController < ApplicationController
  before_filter :authenticate_user!, only: [:ask_a_question]
  before_filter :find_transactable_type, only: [:show]
  before_filter :find_location, only: [:show, :ask_a_question]
  before_filter :find_listing, only: [:show, :ask_a_question]
  before_filter :redirect_to_invidivual_page_if_enabled
  before_filter :redirect_if_location_deleted, only: [:show, :ask_a_question]
  before_filter :redirect_if_location_custom_page, only: [:show, :ask_a_question]
  before_filter :find_listings, only: [:show, :ask_a_question]
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
    @reviews = @listing.reviews.paginate(page: params[:reviews_page])
    @rating_questions = RatingSystem.active_with_subject(RatingConstants::TRANSACTABLE).try(:rating_questions)
  end

  def ask_a_question
    render :show
  end

  def w_hotels
    @location = Location.find_by_custom_page("w_hotels")
    @listing = @location.listings.first
    restore_initial_bookings_from_stored_reservation
  end

  def redirect
    tt = TransactableType.find(params[:id])
    loc = Location.find(params[:location_id])
    listing = Transactable.find(params[:listing_id].split("-").first)

    redirect_to transactable_type_location_listing_path(tt, loc, listing), status: 301
  end

  private

  def find_location
    @location = Location.find(params[:id])
  end

  def find_listing
    # tmp hack before migrating to Rails 4.1 - with deleted breaks default scope
    if params[:listing_id]
      scope = @location.listings.includes(:transactable_type)
      scope = scope.for_transactable_type_id(@transactable_type.id) if @transactable_type.present?
      @listing = scope.find(params[:listing_id])
    end

  rescue
    # We used to use to_param set as $id-$name.parameterize, so
    # we're assuming the first - will separate id from the parameterized name.
    #
    old_id = params[:listing_id].split("-").first
    old_slug = params[:listing_id].split("-").try(:[], 1..-1).try(:join, "-")

    @listing = scope.find_by(id: old_id).presence || scope.find_by(slug: old_slug)
    if @listing.present?
      redirect_to location_listing_path(@location, @listing), status: 301
    else
      flash[:warning] = t('flash_messages.locations.listing_removed')
      redirect_to request.referer
    end
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

  def find_listings
    @listings = @location.listings.includes(:transactable_type)
    if @transactable_type.present?
      @listings = @listings.for_transactable_type_id(@transactable_type.id)
    else
      @listings = @listings.for_groupable_transactable_types
    end
  end

  def redirect_if_no_active_listings
    if current_user_can_manage_location?
      # We only show non-draft listings even to the admin because otherwise weird errors can occur
      # when showing him incomplete listings, especially if he tries to book it
      @listings = @listings.active

      # If from among the non-draft listings remaining all are enabled=false (that is, visible.empty?)
      # we show a warning to the admin
      flash.now[:warning] = t('flash_messages.locations.browsing_no_listings') if @listings.visible.empty?
    else
      @listings = @listings.searchable
    end
    if @listings.empty?
      # If location doesn't have any listings, redirects to search page with notice
      flash[:warning] = t('flash_messages.locations.no_listings')
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
    if @listing.try(:transactable_type).try(:show_page_enabled)
      redirect_to transactable_type_location_listing_path(@listing.transactable_type, @location, @listing, restore_reservations: params[:restore_reservations]), status: :found
    end
  end

  def find_transactable_type
    @transactable_type = params[:transactable_type_id].present? ? TransactableType.find(params[:transactable_type_id]) : nil
    if @transactable_type.try(:groupable_with_others)
      redirect_to location_path(params.except(:transactable_type_id)), status: :found
    end
  end

end
