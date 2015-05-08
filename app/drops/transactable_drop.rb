class TransactableDrop < BaseDrop

  include AvailabilityRulesHelper
  include SearchHelper
  include MoneyRails::ActionViewExtension

  attr_reader :transactable

  delegate :id, :location_id, :name, :location, :transactable_type, :description, :action_hourly_booking?, :action_rfq?, :creator, :administrator, :last_booked_days,
   :defer_availability_rules?, :lowest_price, :company, :properties, :quantity, :administrator_id, :has_photos?, :book_it_out_available?,
   :action_free_booking?, :currency, :exclusive_price_available?, :only_exclusive_price_available?, to: :transactable
  delegate :bookable_noun, :bookable_noun_plural, :action_price_per_unit, to: :transactable_type
  delegate :latitude, :longitude, :address, to: :location
  delegate :dashboard_url, :search_url, to: :routes

  def initialize(transactable)
    @transactable = transactable
  end

  def availability
    pretty_availability_sentence(@transactable.availability).to_s
  end

  def manage_guests_dashboard_url
    routes.dashboard_company_host_reservations_path(:token => @transactable.administrator.try(:temporary_token))
  end

  def manage_guests_dashboard_url_with_tracking
    routes.dashboard_company_host_reservations_path(:token => @transactable.administrator.try(:temporary_token), :track_email_event => true)
  end

  def search_url_with_tracking
    routes.search_path(track_email_event: true)
  end

  def url
    routes.transactable_type_location_listing_path(@transactable.transactable_type, @transactable.location, @transactable)
  end

  alias_method :listing_url, :url

  def street
    @transactable.location.street
  end

  def photo_url
    @transactable.photos.first.try(:image_url, :space_listing).presence || image_url(Placeholder.new(:width => 410, :height => 254).path).to_s
  end

  def from_money_period
    price_information(@transactable)
  end

  def manage_listing_url_with_tracking
    routes.edit_dashboard_company_transactable_type_transactable_path(@transactable.location, @transactable, track_email_event: true, token: @transactable.administrator.try(:temporary_token))
  end

  def space_wizard_list_path
    routes.new_user_session_path(:return_to => routes.transactable_type_space_wizard_list_path(transactable_type))
  end

  def space_wizard_list_url_with_tracking
    routes.transactable_type_space_wizard_list_path(transactable_type, token: @user.try(:temporary_token), track_email_event: true)
  end

  def amenities
    @amenities ||= @transactable.amenities.pluck(:name)
  end

  def new_user_message_path
    routes.new_listing_user_message_path(@transactable)
  end

  def amenities
    @transactable.amenities.order('name ASC').pluck(:name)
  end

  def photos
    @transactable.photos_metadata
  end

  def price_per_unit?
    action_price_per_unit
  end

  def exclusive_price
    @transactable.exclusive_price.to_s
  end

  def new_ticket_url
    routes.new_listing_ticket_path(@transactable)
  end

  def reviews_count
    @transactable.reviews.count
  end

end

