class Locations::ListingsController < ApplicationController
  before_filter :find_listing, only: [:show]
  before_filter :redirect_to_transactable_type_version
  before_filter :find_location, only: [:show]
  before_filter :redirect_to_location_if_show_page_disabled
  before_filter :redirect_if_listing_inactive, only: [:show]

  def show
    restore_initial_bookings_from_stored_reservation
    @listing.track_impression(request.remote_ip)
    event_tracker.viewed_a_listing(@listing, { logged_in: user_signed_in? })
    @reviews = @listing.reviews.paginate(page: params[:reviews_page])
    render formats: [:html]
  end

  protected

  def find_listing
    @listing = Transactable.find(params[:id])
  end

  def find_location
    @location = Location.find(@listing.location_id)
  end

  def redirect_to_location_if_show_page_disabled
    unless @listing.transactable_type.show_page_enabled
      redirect_to transactable_type_location_path(@listing.transactable_type, @location, @listing, params.extract!(:start_date, :end_date)), status: :found
    end
  end

  def redirect_if_listing_inactive
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

  def current_user_can_manage_listing?
    user_signed_in? && (current_user.can_manage_listing?(@listing) || current_user.instance_admin?)
  end

  def redirect_to_transactable_type_version
    if params[:transactable_type_id].nil?
      redirect_to transactable_type_location_listing_path(@listing.transactable_type, @listing.location, @listing)
    end
  end

end

