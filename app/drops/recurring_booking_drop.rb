# frozen_string_literal: true
class RecurringBookingDrop < OrderDrop
  # @return [RecurringBookingDrop]
  attr_reader :recurring_booking

  # @!method quantity
  #   @return [Integer] Ordered quantity
  # @!method total_price
  #   @return [String] total price for this recurring booking order rendered according to
  #     the global currency rendering rules, or 'Free!' if free
  # @!method rejection_reason
  #   @return [String] Rejection reason for this recurring booking order if rejected
  # @!method owner
  #   @return [UserDrop] User owner of the order
  # @!method has_service_fee?
  #   @return [Boolean] whether the order includes a service fee
  # @!method with_delivery?
  #   @return [Boolean] false
  # @!method last_unpaid_amount
  #   @return [String] last unpaid amount for this recurring booking rendered according
  #     to the global currency rendering rules
  # @!method total_payable_to_host_formatted
  #   @return [String] total amount payable to host formatted using the global
  #     currency formatting rules
  # @!method total_units_text
  #   @return [String] empty string
  # @!method manage_booking_status_info
  #   @return [String] formatted string instructing the user to confirm their booking before expiration if unconfirmed, otherwise
  #     renders an icon with the status information
  # @!method manage_booking_status_info_new
  #   @return [String] formatted string instructing the user to confirm their booking before expiration
  delegate :quantity, :total_price, :rejection_reason, :owner, :has_service_fee?,
           :with_delivery?, :last_unpaid_amount, :total_payable_to_host_formatted, :total_units_text,
           :manage_booking_status_info, :manage_booking_status_info_new,
           to: :recurring_booking

  # @!method transactable_type
  #   @return [TransactableTypeDrop] Transactable type to which this transactable belongs
  # @!method action_hourly_booking?
  #   @return [Boolean] True if hourly booking is available for this transactable
  delegate :transactable_type, :action_hourly_booking?, to: :transactable

  # @!method bookable_noun
  #   @return [String] Represents the item to be booked (e.g. desk, room etc.)
  # @!method translated_bookable_noun
  #   @return [String] represents the item to be booked (e.g. desk, room etc.)
  #     taken from translations (e.g. translation key of the form 'transactable_type.desk.name')
  delegate :bookable_noun, :translated_bookable_noun, to: :transactable_type

  def initialize(recurring_booking)
    @order = @recurring_booking = recurring_booking.decorate
  end

  # @return [TransactableDrop] TransactableDrop object from the transactable
  #   associated with this recurring booking
  # @todo -- investigate if we need to couple this so tightly -- i dont know, just signalizing possibility of complicated code
  # if we decide to keep it i vote for much more explanation of how to use those kinds of inherited drops
  def transactable
    @transactable_drop ||= @recurring_booking.transactable.to_liquid
  end

  # @return [LocationDrop] LocationDrop object from the location associated with
  #   this recurring booking
  # @todo -- investigate if we need to couple this so tightly -- i dont know, just signalizing possibility of complicated code
  # if we decide to keep it i vote for much more explanation of how to use those kinds of inherited drops
  def location
    @location_drop ||= @recurring_booking.location.to_liquid
  end

  # @return [Boolean] whether there is a rejection reason for this recurring_booking
  # @todo -- depracate per DIY approach -- .rejection_reason != blank in liquid should be enough
  def has_rejection_reason
    !rejection_reason.to_s.empty?
  end

  # @return [String] the search query URL for the same type of service as this recurring_booking and for this location
  # @todo -- depracate in favor of filter
  def search_url
    routes.search_path(q: location_query_string(@recurring_booking.transactable.location), transactable_type_id: @recurring_booking.transactable.transactable_type.id)
  end

  # @return [String] url to the dashboard area for managing own recurring_bookings
  # @todo -- depracate in favor of filter
  def bookings_dashboard_url
    routes.dashboard_user_recurring_bookings_path(token_key => @recurring_booking.owner.temporary_token)
  end

  # @return [String] url to the dashboard area showing a list of recurring bookings to be managed including this one;
  #   it takes the user to the correct area in the dashboard according to the state of the order (confirmed, unconfirmed,
  #   overdued, archived etc.)
  # @todo -- depracate in favor of filter
  def guest_show_url
    path = case @recurring_booking.state
           when 'confirmed', 'unconfirmed', 'overdued'
             'active_dashboard_user_recurring_bookings_url'
           else
             'archived_dashboard_user_recurring_bookings_url'
           end
    routes.send(path, anchor: "recurring_booking_#{@recurring_booking.id}", host: PlatformContext.current.decorate.host, token_key => @recurring_booking.owner.temporary_token)
  end

  # @return [String] url to the dashboard area for managing own reservations with tracking
  # @todo -- depracate in favor of filter
  def bookings_dashboard_url_with_tracking
    routes.dashboard_user_recurring_bookings_path(token_key => @recurring_booking.owner.temporary_token)
  end

  # @return [String] reservation starting date formatted information
  # @todo -- date could be manager somewhere else + translation used in filter
  def dates_summary_with_hr
    "#{I18n.t('recurring_reservations_review.starts_from')} #{I18n.l(@recurring_booking.starts_at.to_date, format: :short)}"
  end

  # @return [String] url to the dashboard area for managing received bookings
  # @todo -- depracate in favor of filter
  def manage_guests_dashboard_url
    routes.dashboard_company_host_recurring_bookings_path
  end

  # @return [DateTime] date at which the reservation was created
  # @todo -- investigate if it would be a good idea to have a filter that would pull out any date (created, updated, start, etc)
  # based on object and keyword passed (ie. recurring_booking | date: 'created_at' | format 'DD-MM-YYYY')
  def created_at
    @recurring_booking.created_at
  end

  # @return [String] url for confirming the recurring booking
  # @todo -- depracate in favor of filter
  def reservation_confirm_url
    routes.confirm_dashboard_company_host_recurring_booking_path(@recurring_booking, listing_id: @recurring_booking.transactable, token_key => @recurring_booking.creator.try(:temporary_token))
  end

  # @return [String] url for confirming the recurring booking with tracking
  # @todo -- depracate in favor of filter
  def reservation_confirm_url_with_tracking
    routes.confirm_dashboard_company_host_recurring_booking_path(@recurring_booking, listing_id: @recurring_booking.transactable, token_key => @recurring_booking.creator.try(:temporary_token))
  end

  # @return [DateTime] reservation date (first date)
  def start_date
    @recurring_booking.starts_at
  end

  # @return [String] string representing the plural of the item to be booked (e.g. desks, rooms etc.),
  #   pluralized, and taken from the translations (e.g. translation key of the form 'transactable_type.desk.name')
  # @todo -- depracate in favor of usual translation
  def bookable_noun_plural
    transactable_type.translated_bookable_noun(4)
  end

  # @return [String] current state of the object (e.g. unconfirmed etc.) as a human readable string
  # @todo -- rename? "state" should be enough
  def state_to_string
    @recurring_booking.state.to_s.humanize
  end

  # @return [String] translated number of units and unit for booking using the translation key
  #   'dashboard.user_recurring_bookings.every_unit_price' (e.g. 'Every month price')
  # @todo -- investigate if we can manage units in filter and get allow more DIY approach here
  def booking_units
    @recurring_booking.transactable_pricing.decorate.units_translation('dashboard.user_recurring_bookings.every_unit_price')
  end
end
