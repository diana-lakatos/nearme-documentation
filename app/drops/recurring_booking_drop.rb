class RecurringBookingDrop < BaseDrop

  attr_reader :recurring_booking

  # quantity
  #   number of reserved items
  # subtotal_price
  #   subtotal price as a string (including currency symbol etc.)
  # service_fee_guest
  #   guest part of the service_fee
  # total_price
  #   total_price as a string (including currency symbol etc.)
  # pending?
  #   returns true if the payment status is pending
  # listing
  #   service object for which the booking occurred
  # credit_card_payment?
  #   returns true if the payment method for the reservation was credit card
  # rejection_reason
  #   returns the reason as string for which the reservation has been rejected
  # owner
  #   user object containing the person who made the booking
  # last_unpaid_amount
  #   Last amount we weren't able to charge
  # total_payable_to_host_formatted
  #   total amount payable to host formatted as a string with currency symbol and cents
  delegate :quantity, :subtotal_price, :guest_service_fee, :total_price, :pending?,
    :credit_card_payment?, :rejection_reason, :owner, :interval, :has_service_fee?,
    :last_unpaid_amount, :total_payable_to_host_formatted, to: :recurring_booking

  # transactable_type
  #   the object describing the type of item to be booked (e.g. desk, room etc.)
  # action_hourly_booking?
  #   returns true if hourly booking is available for this listing
  delegate :transactable_type, :action_hourly_booking?, to: :listing

  # bookable_noun
  #   string representing the item to be booked (e.g. desk, room etc.)
  # translated_bookable_noun
  #   string representing translated item to be booked (e.g. desk, room etc.)
  delegate :bookable_noun, :translated_bookable_noun, to: :transactable_type

  def initialize(recurring_booking)
    @recurring_booking = recurring_booking.decorate
  end

  def listing
    @listing_drop ||= recurring_booking.listing.to_liquid
  end

  def location
    @location_drop ||= recurring_booking.location.to_liquid
  end

  # returns true if there is a rejection reason for this reservation
  def has_rejection_reason
    !rejection_reason.to_s.empty?
  end

  # returns the search query URL for the same type of service as this reservation and for this location
  def search_url
    routes.search_path(q: location_query_string(@recurring_booking.listing.location), transactable_type_id: @recurring_booking.listing.transactable_type.id)
  end

  # url to the dashboard area for managing own reservations
  def bookings_dashboard_url
    routes.dashboard_user_recurring_bookings_path(token_key => @recurring_booking.owner.temporary_token)
  end

  # url to the dashboard area for managing own reservations with tracking
  def bookings_dashboard_url_with_tracking
    routes.dashboard_user_recurring_bookings_path(token_key => @recurring_booking.owner.temporary_token, track_email_event: true)
  end

  # url to the dashboard area for managing received bookings
  def manage_guests_dashboard_url
    routes.dashboard_company_host_recurring_bookings_path
  end

  # date at which the reservation was created formatted as a string
  def created_at
    @recurring_booking.created_at
  end

  # url for confirming the recurring booking
  def reservation_confirm_url
    routes.confirm_dashboard_company_host_recurring_booking_path(@recurring_booking, listing_id: @recurring_booking.listing, token_key => @recurring_booking.creator.try(:temporary_token))
  end

  # url for confirming the recurring booking with tracking
  def reservation_confirm_url_with_tracking
    routes.confirm_dashboard_company_host_recurring_booking_path(@recurring_booking, listing_id: @recurring_booking.listing, token_key => @recurring_booking.creator.try(:temporary_token), :track_email_event => true)
  end

  # reservation date (first date)
  def start_date
    @recurring_booking.start_on
  end

  # string representing the plural of the item to be booked (e.g. desks, rooms etc.)
  def bookable_noun_plural
    transactable_type.translated_bookable_noun(4)
  end

  # current state of the object (e.g. unconfirmed etc.) as a humanized string
  def state_to_string
    @recurring_booking.state.to_s.humanize
  end

end
