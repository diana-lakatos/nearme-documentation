# frozen_string_literal: true
class TransactableDrop < BaseDrop
  include AvailabilityRulesHelper
  include SearchHelper
  include MoneyRails::ActionViewExtension
  include CategoriesHelper
  include ClickToCallButtonHelper

  # location_id
  #   numeric identifier of the location object to which this listing belongs
  # name
  #   name of this listing
  # location
  #   location object to which this listing belongs
  # transactable_type
  #   the service type to which this particular listing belongs
  # description
  #   the description for this listing
  # action_hourly_booking?
  #   returns true if hourly booking is available for this listing
  # creator
  #   the user object representing the creator of this listing
  # administrator
  #   the user object representing the administrator of this listing (if present)
  # last_booked_days
  #   number of days since the last reservation has been made
  # lowest_price
  #   lowest price for this listing
  # lowest_full_price
  #   lowest price listing for this location (i.e. including service fees and mandatory additional charges)
  # company
  #   the company object to which this listing belongs
  # properties
  #   collection object containing the custom properties for this listing
  # quantity
  #   quantity of bookable items for any given date
  # administrator_id
  #   numeric identifier for the administrator of this listing
  # has_photos?
  #   returns true if there are any photos for this listing
  # book_it_out_available?
  #   return true if the "book it out" action is available for this listing
  # action_free_booking?
  #   returns true if free booking has been specifically enabled for this listing
  # currency
  #   returns the currency used for prices relating to this listing
  # exclusive_price_available?
  #   returns true if an exclusive price has been defined for this listing
  # only_exclusive_price_available?
  #   returns true if the exclusive price defined for this listing is the only price defined for this listing
  # possible_express_checkout
  #   returns true if paypal express gateway defined for country assigned to transactable
  # attachments
  #   array of (seller) attachments for this listing
  # deposit_amount_cents
  #   deposit amount cents
  # average_rating
  #   average rating for this listing
  delegate :id, :location_id, :name, :location, :transactable_type, :description, :action_hourly_booking?, :creator, :creator_id, :administrator, :last_booked_days,
           :lowest_price, :company, :properties, :quantity, :administrator_id, :has_photos?, :book_it_out_available?, :action_type,
           :currency, :exclusive_price_available?, :only_exclusive_price_available?, :capacity, :approval_requests, :updated_at,
           :attachments, :express_checkout_payment?, :overnight_booking?, :is_trusted?, :lowest_full_price, :slug, :attachments, :confirm_reservations,
           :to_key, :model_name, :deposit_amount_cents, :customizations, :to_param, :hours_for_guest_to_confirm_payment, :availability_exceptions,
           :action_free_booking?, :average_rating, :time_based_booking?, :transactable_collaborators, :collaborating_users, :approved_transactable_collaborators,
           :user_messages, :line_item_orders, :state, :created_at, :pending?, :completed?, :transactable_type_id, :tags, to: :source

  # action_price_per_unit
  #   returns true if there is a single unit available of the transactable item for a given time period
  delegate :action_price_per_unit, to: :transactable_type

  # latitude
  #   returns the latitude of the location of this listing as a floating point number
  # longitude
  #   returns the longitude of the location of this listing as a floating point number
  delegate :latitude, :longitude, :address, to: :location

  # dashboard_url
  #   url to the user's dashboard
  # search_url
  #   url to the search section of the marketplace
  delegate :dashboard_url, :search_url, to: :routes

  # action_rfq?
  #   returns true if request for quote is available for this listing
  delegate :action_rfq?, to: :action_type

  def class_name
    'Transactable'
  end

  #   name of representing the bookable object transactable on the marketplace as a string (e.g. desk, room etc.)
  def bookable_noun
    transactable_type.to_liquid.bookable_noun
  end

  #   name of representing the bookable object (plural) transactable on the marketplace as a string (e.g. desks, rooms etc.)
  def bookable_noun_plural
    transactable_type.to_liquid.bookable_noun_plural
  end

  #   the name of the type of entity selling the products
  def lessor
    transactable_type.to_liquid.lessor
  end

  #   the name of the type of entity buying the products
  def lessee
    transactable_type.to_liquid.lessee
  end

  #   pluralized version of lessor
  def lessors
    transactable_type.to_liquid.lessors
  end

  #   pluralized version of lessee
  def lessees
    transactable_type.to_liquid.lessees
  end

  # availability for this listing as a string in a human-readable format
  def availability
    pretty_availability_sentence(@source.availability).to_s
  end

  # availability by days
  def availability_by_days
    days = {}

    if @source.availability.present?
      @source.availability.rules.each do |rule|
        rule.days.each do |day|
          days[day] ||= []

          days[day] << [rule.open_hour, rule.close_hour, pretty_availability_rule_time_with_time_zone(rule, @source.timezone)]
        end
      end
    end

    days.each do |day, _value|
      days[day].sort! { |time1, time2| time1[0] <=> time2[0] }
    end

    sorted_days = days.sort do |d1, d2|
      if d1[0] != 0 && d2[0] != 0
        d1[0] <=> d2[0]
      elsif d1[0] == 0
        +1
      else
        -1
      end
    end

    sorted_days.map { |day| [Date::ABBR_DAYNAMES[day[0]], day[1]] }
  end

  # available days
  def available_days
    days = {}
    (0..6).each { |day| days[day] = false }

    if @source.availability.present?
      @source.availability.rules.each do |rule|
        rule.days.each do |day|
          days[day] = true
        end
      end
    end

    sorted_days = days.sort do |d1, d2|
      if d1[0] != 0 && d2[0] != 0
        d1[0] <=> d2[0]
      elsif d1[0] == 0
        +1
      else
        -1
      end
    end

    sorted_days.map { |day| [Date::ABBR_DAYNAMES[day[0]], day[1]] }
  end

  # url to the dashboard area for managing received bookings
  def manage_guests_dashboard_url
    routes.dashboard_company_host_reservations_path(token_key => @source.administrator.try(:temporary_token))
  end

  def index_url
    routes.dashboard_company_transactable_type_transactables_path(@source.transactable_type, anchor: "transactable_#{@source.id}", token_key => @source.administrator.try(:temporary_token))
  end

  def in_progress_index_url
    routes.dashboard_company_transactable_type_transactables_path(@source.transactable_type, status: 'in progress', anchor: "transactable_#{@source.id}", token_key => @source.administrator.try(:temporary_token))
  end

  def in_progress_index_url_without_token
    routes.dashboard_company_transactable_type_transactables_path(@source.transactable_type, status: 'in progress', anchor: "transactable_#{@source.id}")
  end

  # url to the dashboard area for managing received bookings, with tracking
  def manage_guests_dashboard_url_with_tracking
    routes.dashboard_company_host_reservations_path(token_key => @source.administrator.try(:temporary_token))
  end

  # url to the search section of the marketplace, with tracking
  def search_url_with_tracking
    routes.search_path
  end

  # url to display favorite button
  def wish_list_path
    routes.wish_list_path(id: @source.id, wishlistable_type: 'Transactable')
  end

  def wish_list_bulk_path
    routes.bulk_show_wish_lists_path
  end

  # has inappropriate report for user
  def inappropriate_report_path
    routes.inappropriate_report_path(id: @source.id, reportable_type: 'Transactable')
  end

  # url to the listing page for this listing
  def url
    @source.show_url
  end
  alias listing_url url

  def show_path
    @source.show_path
  end

  # url to the listing page for this listing - location prefixed. Deprecated, pointing to url
  def location_prefixed_path
    url
  end

  # street name for the location of this listing
  def street
    @source.location.street
  end

  # returns the url to the first image for this listing, or, if missing, the url to a placeholder image
  def photo_url
    photos.try(:first).try(:[], :space_listing) || image_url(Placeholder.new(width: 410, height: 254).path).to_s
  end

  def photo_medium_url
    @source.photos.first.try(:image_url, :medium)
  end

  # returns a string of the type "From $currency_amount / period"
  def from_money_period
    price_information(@source)
  end

  def space_placeholder
    image_url(Placeholder.new(width: 895, height: 554).path).to_s
  end

  # url to the section in the app for managing this listing, with tracking
  def manage_listing_url_with_tracking
    if PlatformContext.current.instance.is_community?
      urlify(routes.edit_dashboard_project_type_project_path(@source.transactable_type, @source, token_key => @source.creator.try(:temporary_token), anchor: :collaborators))
    else
      routes.edit_dashboard_company_transactable_type_transactable_path(@source.location, @source, token_key => @source.administrator.try(:temporary_token))
    end
  end

  # url to the application wizard for publishing a new listing
  def space_wizard_list_path
    routes.new_user_session_path(return_to: routes.transactable_type_space_wizard_list_path(transactable_type))
  end

  # url to the application wizard for publishing a new listing, with tracking
  def space_wizard_list_url_with_tracking
    routes.transactable_type_space_wizard_list_path(transactable_type, token_key => @user.try(:temporary_token))
  end

  # url to the section of the app for sending a message to the administrator
  # of this listing using the internal messaging platform
  def new_user_message_path
    routes.new_listing_user_message_path(@source)
  end

  # array of photo items; each photo item is a hash with the keys being:
  #   space_listing - photo having a dimension of the space_listing type
  #   golden - photo having a dimension of the golden type
  #   large - photo having a dimension of the large type
  def photos
    @source.photos_metadata
  end

  # returns true if price_per_unit is enabled for this listing
  def price_per_unit?
    @source.action_type.pricings.any?(&:price_per_measurable_unit?)
  end

  # returns the exclusive price set for this listing as a string
  def exclusive_price
    @source.event_booking.pricing.exclusive_price.to_s
  end

  # returns the url to the section in the app for opening a new
  # support ticket
  def new_ticket_url
    routes.new_listing_ticket_path(@source)
  end

  # returns the total number of reviews for this listing
  def reviews_count
    @source.reviews.count
  end

  # returns hash of categories { "<name>" => { "name" => '<translated_name', "children" => [<collection of chosen values] } }
  def categories
    if @categories.nil?
      @categories = build_categories_hash_for_object(@source, @source.transactable_type.categories.roots.includes(:children))
    end
    @categories
  end

  # returns hash of categories { "<name>" => { "name" => '<translated_name>', "children" => 'string with all children separated with comma' } }
  def formatted_categories
    build_formatted_categories(@source.categories)
  end

  # returns whether or not the listing has seller attachments
  def has_seller_attachments?
    attachments.exists?
  end

  # url for sharing this location on Facebook
  def facebook_social_share_url
    routes.new_listing_social_share_path(@source, provider: 'facebook')
  end

  # url for sharing this location on Twitter
  def twitter_social_share_url
    routes.new_listing_social_share_path(@source, provider: 'twitter')
  end

  # url for sharing this location on LinkedIn
  def linkedin_social_share_url
    routes.new_listing_social_share_path(@source, provider: 'linkedin')
  end

  def booking_module_path
    routes.booking_module_listing_path(@source)
  end

  def click_to_call_button
    build_click_to_call_button_for_transactable(@source)
  end

  def last_search
    @last_search ||= begin
                       JSON.parse(@context.registers[:action_view].cookies['last_search'])
                     rescue
                       {}
                     end
  end

  # is schedule booking enabled for this listing
  def schedule_booking?
    @source.event_booking?
  end

  def actions_allowed?
    !action_type.no_action?
  end

  def all_free_pricings?
    action_type.pricings.any? { |p| !p.is_free_booking? }
  end

  def new_project_collaborator
    transactable_collaborators.build
  end

  def edit_path
    routes.edit_dashboard_company_transactable_type_transactable_path(@source.transactable_type, @source)
  end

  def destroy_path
    routes.dashboard_company_transactable_type_transactable_path(@source.transactable_type, @source)
  end

  def cancel_path
    routes.cancel_dashboard_company_transactable_type_transactable_path(@source.transactable_type, @source)
  end

  def listing_date
    @source.listing_date
  end

  def location_name
    @source.location.try(:name)
  end

  def lowest_price_with_currency
    @source.lowest_price_with_currency
  end

  # user message path
  def user_message_path
    routes.new_transactable_user_message_path(@source)
  end

  def accepted_orders
    line_item_orders.upcoming.confirmed.uniq
  end

  def last_accepted_order
    accepted_orders.last
  end

  def first_accepted_order
    line_item_orders.confirmed.first
  end

  def orders
    line_item_orders.order(created_at: :desc).active.uniq
  end

  def confirmed_order
    line_item_orders.confirmed.first
  end

  def transactable_user_messages
    return [] unless @context['current_user']
    @source.user_messages.where('author_id = :user_id OR thread_recipient_id = :user_id', user_id: @context['current_user'].id)
  end

  # returns ranges of rented periods {from: date, to: date}
  def rented_range_periods
    Time.use_zone(@source.timezone) do
      @source.line_item_orders.with_state(:confirmed).map(&:period_range)
    end
  end

  # returns ranges of unavailable periods {from: date, to: date}
  def unavailable_range_periods
    Time.use_zone(@source.timezone) do
      @source.availability_exceptions.map(&:range)
    end
  end

  # returns json with ranges of rented and unavailable periods {from: date, to: date}
  def unavailable_periods
    (unavailable_range_periods + rented_range_periods).uniq.to_json
  end
end
