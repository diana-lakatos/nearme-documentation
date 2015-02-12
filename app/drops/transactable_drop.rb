class TransactableDrop < BaseDrop

  include AvailabilityRulesHelper
  include SearchHelper
  include MoneyRails::ActionViewExtension

  attr_reader :listing

  delegate :name, :location, :transactable_type, :description, :hourly_reservations?, :creator, :administrator, :last_booked_days, to: :listing
  delegate :bookable_noun, :bookable_noun_plural, to: :transactable_type
  delegate :dashboard_url, :search_url, to: :routes

  def initialize(listing)
    @listing = listing
  end

  def availability
    pretty_availability_sentence(@listing.availability).to_s
  end

  def manage_guests_dashboard_url
    routes.dashboard_host_reservations_path(:token => @listing.administrator.try(:temporary_token))
  end

  def manage_guests_dashboard_url_with_tracking
    routes.dashboard_host_reservations_path(:token => @listing.administrator.try(:temporary_token), :track_email_event => true)
  end

  def search_url_with_tracking
    routes.search_path(track_email_event: true)
  end

  def listing_url
    @listing.transactable_type.show_page_enabled? ? routes.listing_path(@listing) : routes.location_path(@listing.location, @listing)
  end

  def street
    @listing.location.street
  end

  def photo_url
    @listing.has_photos? ? @listing.photos.first.image_url(:space_listing) : image_url(Placeholder.new(:width => 410, :height => 254).path).to_s
  end

  def from_money_period
    price_information(@listing)
  end

  def manage_listing_url_with_tracking
    routes.edit_dashboard_transactable_type_transactable_path(@listing.transactable_type, @listing.location, @listing, track_email_event: true, token: @listing.administrator.try(:temporary_token))
  end

  def space_wizard_list_path
    routes.new_user_session_path(:return_to => routes.transactable_type_space_wizard_list_path(transactable_type))
  end

  def space_wizard_list_url_with_tracking
    routes.transactable_type_space_wizard_list_path(transactable_type, token: @user.try(:temporary_token), track_email_event: true)
  end

end
