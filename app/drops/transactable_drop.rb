# frozen_string_literal: true
class TransactableDrop < BaseDrop
  include AvailabilityRulesHelper
  include SearchHelper
  include MoneyRails::ActionViewExtension
  include CategoriesHelper
  include ClickToCallButtonHelper

  # @!method id
  #   @return [Integer] numeric identifier for this transactable
  # @!method location_id
  #   @return [Integer] Numeric identifier for the location associated with this transactable
  # @!method name
  #   @return [String] Name of the transactable
  # @!method location
  #   @return [LocationDrop] Location object associated with the transactable
  # @!method transactable_type
  #   @return [TransactableTypeDrop] Transactable type to which this transactable belongs
  # @!method description
  #   @return [String] Description for the transactable
  # @!method action_hourly_booking?
  #   @todo Investigate whether this is still used/should be removed
  #   @return [Boolean] Whether hourly booking is possible for this transactable
  # @!method creator
  #   @return [UserDrop] User who created the transactable
  # @!method creator_id
  #   @return [Integer] ID of the user who created the transactable
  # @!method administrator
  #   @return [UserDrop] Administrator user of the listing
  # @!method last_booked_days
  #   @return [Integer, nil] days since the last order for the transactable or nil if no orders
  # @!method lowest_price
  #   @return [Transactable::PricingDrop] object corresponding to the lowest available pricing for this transactable
  # @!method company
  #   @return [CompanyDrop] Company associated with this transactable
  # @!method properties
  #   @return [Hash] custom properties for this transactable
  # @!method quantity
  #   @return [Integer] Quantity of bookable items for any given date
  # @!method administrator_id
  #   @return [Integer] Numeric identifier for the administrator of this listing
  # @!method has_photos?
  #   @return [Boolean] whether there are any photos for this listing
  # @!method book_it_out_available?
  #   @return [Boolean] whether the "book it out" action is available for this listing
  # @!method action_type
  #   Action type available for this transactable
  #   @return [Transactable::ActionTypeDrop]
  # @!method currency
  #   @return [String] currency used for this transactable's pricings
  # @!method exclusive_price_available?
  #   @return [Boolean] whether an exclusive price has been defined for this listing
  # @!method only_exclusive_price_available?
  #   @return [Boolean] whether the exclusive price defined for this listing is the only price defined for this listing
  # @!method capacity
  #   @return [String] Capacity for the transactable (e.g. '7 seats, 10 standing')
  # @!method approval_requests
  #   @return [Array<ApprovalRequestDrop>] Approval requests for this transactable (if approval is required from the marketplace owner)
  # @!method updated_at
  #   Last time when the transactable has been updated
  #   @return [DateTime]
  # @!method attachments
  #   @return [Array<CkeditorAssetDrop>] Seller attachments for this transactable (documents available to purchasers/collaborators/etc.)
  # @!method express_checkout_payment?
  #   @return [Boolean] whether PayPal Express Checkout is the marketplace's payment method
  # @!method overnight_booking?
  #   @return [Boolean] whether overnight booking is enabled for this action type
  # @!method is_trusted?
  #   @return [Boolean] whether the object is trusted (approved ApprovalRequest objects for this object, creator, company)
  # @!method lowest_full_price
  #   @return [Transactable::PricingDrop] lowest price for this location (i.e. including service fees and mandatory additional charges)
  # @!method slug
  #   @return [String] URL friendly identifier for the transactable
  # @!method confirm_reservations
  #   @return [Boolean] Whether reservations/purchases need to be confirmed for this transactable
  # @!method to_key
  #   @return [Array<Integer>] array wrapping the identifer for this object
  # @!method model_name
  #   @return [ActiveModel::Name] used for retrieving name related information
  # @!method customizations
  #   @return [Array<CustomizationDrop>] Customizations for this transactable (allows extra customization through custom attributes)
  # @!method to_param
  #   @return [String] friendly id for the transactable
  # @!method hours_for_guest_to_confirm_payment
  #   @return [Integer] number of hours in which a guest can confirm payment
  # @!method availability_exceptions
  #   @return [Array<ScheduleExceptionRuleDrop>] array of schedule exception rules for future dates
  # @!method action_free_booking?
  #   @return [Boolean] whether free booking is possible for the transactable
  # @!method average_rating
  #   @return [Float] Average rating from users for this transactable
  # @!method time_based_booking?
  #   @return [Boolean] whether the time based booking action type is used for this transactable
  # @!method transactable_collaborators
  #   @return [Array<TransactableCollaborator>] Transactable collaborators list for this transactable
  # @!method collaborating_users
  #   @return [Array<UserDrop>] Approved collaborating users for this transactable
  # @!method approved_transactable_collaborators
  #   @return [Array<TransactableCollaboratorDrop>] Approved TransactableCollaborator objects for this transactable
  # @!method user_messages
  #   @return [Array<UserMessageDrop>] User messages for this transactable (for discussion between clients and hosts)
  # @!method line_item_orders
  #   @return [Array<OrderDrop>] Orders containing this transactable object
  # @!method state
  #   @return [String] State for the order (e.g. pending/completed/cancelled/in progress/etc.)
  # @!method created_at
  #   @return [DateTime] time when the transactable was created
  # @!method pending?
  #   @return [Boolean] whether the transactable is in the pending state
  # @!method completed?
  #   @return [Boolean] whether the transactable is in the completed state
  # @!method transactable_type_id
  #   @return [Integer] Transactable type to which this object belongs
  # @!method tags
  #   @return [Array<TagDrop>] array of tags that this transactable has been tagged with
  delegate :id, :location_id, :name, :location, :transactable_type, :description, :action_hourly_booking?, :creator, :creator_id, :administrator, :last_booked_days,
           :lowest_price, :company, :properties, :quantity, :administrator_id, :has_photos?, :book_it_out_available?, :action_type,
           :currency, :exclusive_price_available?, :only_exclusive_price_available?, :capacity, :approval_requests, :updated_at,
           :attachments, :express_checkout_payment?, :overnight_booking?, :is_trusted?, :lowest_full_price, :slug, :attachments, :confirm_reservations,
           :to_key, :model_name, :customizations, :to_param, :hours_for_guest_to_confirm_payment, :availability_exceptions,
           :action_free_booking?, :average_rating, :time_based_booking?, :transactable_collaborators, :collaborating_users, :approved_transactable_collaborators,
           :user_messages, :line_item_orders, :state, :created_at, :pending?, :completed?, :transactable_type_id, :tags, to: :source

  # @!method action_price_per_unit
  #   @return [Boolean] whether there is a single unit available of the transactable item for a given time period
  delegate :action_price_per_unit, to: :transactable_type

  # @!method latitude
  #   @return [Float] the latitude of the location of this listing as a floating point number
  # @!method longitude
  #   @return [Float] the longitude of the location of this listing as a floating point number
  # @!method address
  #   @return [String] address as a string
  delegate :latitude, :longitude, :address, to: :location

  # @!method dashboard_url
  #   @return [String] url to the user's dashboard
  # @!method search_url
  #   @return [String] url to the search section of the marketplace
  delegate :dashboard_url, :search_url, to: :routes

  # @!method action_rfq?
  #   @return [Boolean] whether the request for quote is available for this listing
  delegate :action_rfq?, to: :action_type

  # @return [String] name of the class (i.e. 'Transactable')
  def class_name
    'Transactable'
  end

  # @return [String] name representing the bookable object transactable on the marketplace as a string (e.g. desk, room etc.)
  # @todo depracate in favor of translation?
  def bookable_noun
    transactable_type.to_liquid.bookable_noun
  end

  # @return [String] name representing the bookable object (plural) transactable on the marketplace as a string (e.g. desks, rooms etc.)
  # @todo depracate in favor of translation?
  def bookable_noun_plural
    transactable_type.to_liquid.bookable_noun_plural
  end

  # @return [String] the name of the type of entity selling the products (e.g. seller, renter etc.)
  # @todo depracate in favor of translation?
  def lessor
    transactable_type.to_liquid.lessor
  end

  # @return [String] the name of the type of entity buying the products (e.g. buyer, client etc.)
  # @todo depracate in favor of translation?
  def lessee
    transactable_type.to_liquid.lessee
  end

  # @return [String] pluralized version of lessor
  # @todo depracate in favor of translation?
  def lessors
    transactable_type.to_liquid.lessors
  end

  # @return [String] pluralized version of lessee
  # @todo depracate in favor of translation?
  def lessees
    transactable_type.to_liquid.lessees
  end

  # @return [String] availability for this listing as a string in a human-readable format
  # @todo depracate in favor of DIY / DIY + translation?
  def availability
    pretty_availability_sentence(@source.availability).to_s
  end

  # @return [Array<Array<(String, Array<Array<(Integer, Integer, String)>>)>>] availability by days
  #   for each day, there's a corresponding array of the form [open_hour, close_hour, formatted_availability_string]
  # @todo investigate if this place is appropriate for this logic -- maybe decorator is more suitable
  # or at least refactor for some readability, "there has to be a better way"
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

  # @return [Array<Array<String, Boolean>>] available days; array of the form [[day_name, is_available], ...]
  # @todo investigate if this place is appropriate for this logic -- maybe decorator is more suitable
  # or at least refactor for some readability, "there has to be a better way"
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

  # @return [String] path to the dashboard area for managing received bookings
  # @todo -- depracate in favor of filter
  def manage_guests_dashboard_url
    routes.dashboard_company_host_reservations_path(token_key => @source.administrator.try(:temporary_token))
  end

  # @return [String] path to the dashboard area for managing listings
  # @todo -- depracate in favor of filter
  def index_url
    routes.dashboard_company_transactable_type_transactables_path(@source.transactable_type, anchor: "transactable_#{@source.id}", token_key => @source.administrator.try(:temporary_token))
  end

  # @return [String] path to the dashboard area for managing listings, "in progress" tab selected
  # @todo -- depracate in favor of filter
  def in_progress_index_url
    routes.dashboard_company_transactable_type_transactables_path(@source.transactable_type, status: 'in progress', anchor: "transactable_#{@source.id}", token_key => @source.administrator.try(:temporary_token))
  end

  # @return [String] path to the dashboard area for managing listings, "in progress" tab selected; without authentication token
  # @todo -- depracate in favor of filter
  def in_progress_index_url_without_token
    routes.dashboard_company_transactable_type_transactables_path(@source.transactable_type, status: 'in progress', anchor: "transactable_#{@source.id}")
  end

  # @return [String] path to the dashboard area for managing received bookings
  # @todo -- depracate in favor of filter
  def manage_guests_dashboard_url_with_tracking
    routes.dashboard_company_host_reservations_path(token_key => @source.administrator.try(:temporary_token))
  end

  # @return [String] path to the search section of the marketplace, with tracking
  # @todo -- depracate in favor of filter
  def search_url_with_tracking
    routes.search_path
  end

  # @return [String] path for the 'add as favorite' button
  # @todo -- depracate in favor of filter
  def wish_list_path
    routes.api_wish_list_items_path(id: @source.id, wishlistable_type: 'Transactable')
  end

  # @return [String] path for generating an inappropriate report for this transactable
  # @todo  -- depracate in favor of filter
  def inappropriate_report_path
    routes.inappropriate_report_path(id: @source.id, reportable_type: 'Transactable')
  end

  # @return [String] url to the main page for this listing
  # @todo  -- depracate in favor of filter
  def url
    @source.show_url
  end
  alias listing_url url

  # @return [String] path to the main page for this listing
  # @todo  -- depracate in favor of filter
  def show_path
    @source.show_path
  end

  # @return [String] url to the listing page for this listing - location prefixed
  # @deprecated pointing to url
  # @todo  -- depracate in favor of filter
  def location_prefixed_path
    url
  end

  # @return [String] street name for the location of this listing
  def street
    @source.location.street
  end

  # @return [String] the url to the first image for this listing, or, if missing, the url to a placeholder image
  # @todo  -- depracate in favor of filter
  def photo_url
    photos.try(:first).try(:[], :space_listing) || image_url(Placeholder.new(width: 410, height: 254).path).to_s
  end

  # @return [String, nil] the url to the first 'medium'-sized image for this listing, nil if not present
  # @todo  -- depracate in favor of filter
  def photo_medium_url
    @source.photos.first.try(:image_url, :medium)
  end

  # @return [String] returns a string of the type "From $currency_amount / period"
  # @todo depracate in favor of DIY / DIY + translation?
  def from_money_period
    price_information(@source)
  end

  # @return [String] url to a placeholder image sized 895x554
  # @todo  -- depracate in favor of filter
  def space_placeholder
    image_url(Placeholder.new(width: 895, height: 554).path).to_s
  end

  # @return [String] url to the section in the app for managing this listing, with tracking
  # @todo  -- depracate in favor of filter (it will also depracate community condition which is nice)
  def manage_listing_url_with_tracking
    if PlatformContext.current.instance.is_community?
      urlify(routes.edit_dashboard_project_type_project_path(@source.transactable_type, @source, token_key => @source.creator.try(:temporary_token), anchor: :collaborators))
    else
      routes.edit_dashboard_company_transactable_type_transactable_path(@source.location, @source, token_key => @source.administrator.try(:temporary_token))
    end
  end

  # @return [String] path to the application wizard for publishing a new listing
  # @todo  -- depracate in favor of filter
  def space_wizard_list_path
    routes.new_user_session_path(return_to: routes.transactable_type_space_wizard_list_path(transactable_type))
  end

  # @return [String] path to the application wizard for publishing a new listing, with tracking
  # @todo  -- depracate in favor of filter
  def space_wizard_list_url_with_tracking
    routes.transactable_type_space_wizard_list_path(transactable_type, token_key => @user.try(:temporary_token))
  end

  # @return [String] path to the section of the app for sending a message to the administrator
  #   of this listing using the internal messaging platform
  # @todo  -- depracate in favor of filter
  def new_user_message_path
    routes.new_listing_user_message_path(@source)
  end

  # @return [Array<Hash{String => String}>] array of photo items; each photo item is a hash of the form:
  #   listing_name: name_of_listing,
  #   some_size_type: url_to_image_of_size_some_size_type,
  def photos
    @source.photos_metadata
  end

  # @return [Boolean] whether price per unit is enabled for this listing
  def price_per_unit?
    @source.action_type.pricings.any?(&:price_per_measurable_unit?)
  end

  # @return [String] the exclusive price set for this listing as a string
  def exclusive_price
    @source.event_booking.pricing.exclusive_price.to_s
  end

  # @return [String] path to the section in the app for opening a new support ticket
  # @todo  -- depracate in favor of filter
  def new_ticket_url
    routes.new_listing_ticket_path(@source)
  end

  # @return [Integer] the total number of reviews for this listing
  # @todo -- depracate (transactable.reviews.count? / | count)
  def reviews_count
    @source.reviews.count
  end

  # @return [Hash{String => Hash{String => String, Array}}] hash of categories { "name" => { "name" => 'translated_name', "children" => [Array of children] } }
  def categories
    if @categories.nil?
      @categories = build_categories_hash_for_object(@source, @source.transactable_type.categories.roots.includes(:children))
    end
    @categories
  end

  # @return [Hash{String => Hash{String => String}}] hash of categories { "name" => { "name" => 'translated_name', "children" => 'string with all children separated with comma' } }
  def formatted_categories
    build_formatted_categories(@source.categories)
  end

  # @return [Boolean] whether or not the listing has seller attachments
  def has_seller_attachments?
    attachments.exists?
  end

  # @return [String] path for sharing this location on Facebook
  # @todo -- depracate in favor of filter
  def facebook_social_share_url
    routes.new_listing_social_share_path(@source, provider: 'facebook')
  end

  # @return [String] path for sharing this location on Twitter
  # @todo -- depracate in favor of filter
  def twitter_social_share_url
    routes.new_listing_social_share_path(@source, provider: 'twitter')
  end

  # @return [String] path for sharing this location on LinkedIn
  # @todo -- depracate in favor of filter
  def linkedin_social_share_url
    routes.new_listing_social_share_path(@source, provider: 'linkedin')
  end

  # @return [String] path for rendering the booking module for this transactable
  # @todo -- depracate in favor of filter
  def booking_module_path
    routes.booking_module_listing_path(@source)
  end

  # @return [String, nil] click to call button for this transactable if enabled for this
  #   marketplace
  def click_to_call_button
    build_click_to_call_button_for_transactable(@source)
  end

  # @return [Hash{String => String}] hash of the parameters for the last performed search
  def last_search
    @last_search ||= begin
                       JSON.parse(@context.registers[:action_view].cookies['last_search'])
                     rescue
                       {}
                     end
  end

  # @return [Boolean] is schedule booking enabled for this listing
  def schedule_booking?
    @source.event_booking?
  end

  # @return [Boolean] whether there are any actions available for this listing (i.e. the listing
  #   is bookable/purchasable in some form)
  def actions_allowed?
    !action_type.no_action?
  end

  # @return [Boolean] whether there are non-free pricings for this booking
  # @todo Wrong/inconsistent method name
  def all_free_pricings?
    action_type.pricings.any? { |p| !p.is_free_booking? }
  end

  # @return [TransactableCollaboratorDrop] transactable collaborator object initialized for this transactable
  def new_project_collaborator
    transactable_collaborators.build
  end

  # @return [String] path to editing this transactable in the user's dashboard
  # @todo -- depracate in favor of filter
  def edit_path
    routes.edit_dashboard_company_transactable_type_transactable_path(@source.transactable_type, @source)
  end

  # @return [String] path to deleting this transactable in the user's dashboard
  # @todo -- depracate in favor of filter
  def destroy_path
    routes.dashboard_company_transactable_type_transactable_path(@source.transactable_type, @source)
  end

  # @return [String] path to cancelling this transactable (object will be moved to cancelled state)
  # @todo -- depracate in favor of filter
  def cancel_path
    routes.cancel_dashboard_company_transactable_type_transactable_path(@source.transactable_type, @source)
  end

  # @return [String] formatted date when the transactable was created
  # @todo -- depracate in favor of filter
  def listing_date
    @source.listing_date
  end

  # @return [String, nil] name for this location's transactable
  # @todo -- investigate if this can be replaced with more general method (ie. name in transactable.location object)
  def location_name
    @source.location.try(:name)
  end

  # @return [String] formatted lowest price for this transactable including currency;
  #   e.g. "£100 <span>/ fixed price</span>"
  def lowest_price_with_currency
    @source.lowest_price_with_currency
  end

  # @return [String] path for creating a new user message for this transactable (uses the internal messaging
  #   system for discussion between clients and hosts)
  def user_message_path
    routes.new_transactable_user_message_path(@source)
  end

  # @return [Array<OrderDrop>] confirmed, upcoming (not archived/expired) orders for this transactable
  # @todo -- depracate (transactable.orders.accepted ?)
  def accepted_orders
    line_item_orders.upcoming.confirmed.uniq
  end

  # @return [OrderDrop, nil] last confirmed, upcoming (not archived/expired) order for this transactable or nil if not present
  # @todo -- depracate in favor of filter (transactables.orders.accepted | last? Or allow usage of .last)
  def last_accepted_order
    accepted_orders.last
  end

  # @return [OrderDrop, nil] first confirmed or archived order for this transactable or nil if not present
  # @todo -- depracate in favor of filter (transactables.orders.accepted | first? Or allow usage of .first)
  def first_accepted_order
    line_item_orders.confirmed_or_archived.first
  end

  # @return [Array<OrderDrop>] array of active orders (not in the inactive state) for this transactable sorted descendingly by creation date
  # @todo investigate if orders should be tied to transactable? probably, but maybe ... :)
  def orders
    line_item_orders.order(created_at: :desc).active.uniq
  end

  # @return [OrderDrop, nil] first confirmed order for this transactable or nil if not present
  # @todo -- depracate in favor of filter (transactables.orders.confirmed | first? Or allow usage of .first)
  def confirmed_order
    line_item_orders.confirmed.first
  end

  # @return [OrderDrop, nil] first confirmed order for this transactable or nil if not present
  # @todo -- depracate in favor of filter (transactables.orders.confirmed | first? Or allow usage of .first)
  def confirmed_or_archived_order
    line_item_orders.confirmed_or_archived.first
  end

  # @return [Array<UserMessageDrop>] array of user messages (internal messaging system for discussion between clients and hosts)
  #   for this transactable and for which this user is a recipient or an author
  def transactable_user_messages
    return [] unless @context['current_user']
    @source.user_messages.where('author_id = :user_id OR thread_recipient_id = :user_id', user_id: @context['current_user'].id)
  end

  # @return [Array<Hash{Symbol => Date}>] returns ranges of rented periods !{from: date, to: date}
  def rented_range_periods
    Time.use_zone(@source.timezone) do
      @source.line_item_orders.with_state(:confirmed).map(&:period_range)
    end
  end

  # @return [Array<Hash{Symbol => Date}>] returns ranges of unavailable periods !{from: date, to: date}
  # @todo Investigate malfunctioning method / availability_exceptions can be nil
  def unavailable_range_periods
    Time.use_zone(@source.timezone) do
      @source.availability_exceptions.map(&:range)
    end
  end

  # @return [String] returns json with ranges of rented and unavailable periods !{from: date, to: date}
  # @todo Investigate malfunctioning method: unavailable_range_periods does not work correctly
  def unavailable_periods
    (unavailable_range_periods + rented_range_periods).uniq.to_json
  end

  # @return [String] cover photo url for the transactable
  # @todo -- depracate in favor of filter
  def cover_photo_url
    @source.cover_photo&.image&.url(:golden)
  end
end
