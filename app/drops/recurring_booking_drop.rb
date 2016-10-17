class RecurringBookingDrop < OrderDrop

  # @return [RecurringBooking]
  attr_reader :recurring_booking

  # @!method quantity
  #   Ordered quantity
  #   @return (see Order#quantity)
  # @!method total_price
  #   @return (see RecurringBookingDecorator#total_price)
  # @!method rejection_reason
  #   Rejection reason for this recurring booking order if rejected
  #   @return (see Order#rejection_reason)
  # @!method owner
  #   User owner of the order
  #   @return (see Order#owner)
  # @!method has_service_fee?
  #   @return [Boolean] whether the order includes a service fee
  # @!method with_delivery?
  #   @return (see RecurringBooking#with_delivery?)
  # @!method last_unpaid_amount
  #   @return (see RecurringBookingDecorator#last_unpaid_amount)
  # @!method total_payable_to_host_formatted
  #   @return (see RecurringBookingDecorator#total_payable_to_host_formatted)
  # @!method total_units_text
  #   @return (see RecurringBookingDecorator#total_units_text)
  # @!method manage_booking_status_info
  #   @return (see RecurringBookingDecorator#manage_booking_status_info)
  # @!method manage_booking_status_info_new
  #   @return (see RecurringBookingDecorator#manage_booking_status_info_new)
  delegate :quantity, :total_price, :rejection_reason, :owner, :has_service_fee?,
           :with_delivery?, :last_unpaid_amount, :total_payable_to_host_formatted, :total_units_text,
           :manage_booking_status_info, :manage_booking_status_info_new,
           to: :recurring_booking

  # @!method transactable_type
  #   Transactable type to which this transactable belongs
  #   @return (see Transactable#transactable_type)
  # @!method action_hourly_booking?
  #   True if hourly booking is available for this transactable
  #   @return (see Transactable#action_hourly_booking)
  delegate :transactable_type, :action_hourly_booking?, to: :transactable

  # @!method bookable_noun
  #   Represents the item to be booked (e.g. desk, room etc.)
  #   @return (see TransactableType#bookable_noun)
  # @!method translated_bookable_noun
  #   @return (see TranslationManager#translated_bookable_noun)
  delegate :bookable_noun, :translated_bookable_noun, to: :transactable_type

  def initialize(recurring_booking)
    @order = @recurring_booking = recurring_booking.decorate
  end

  # @return [TransactableDrop] TransactableDrop object from the transactable
  #   associated with this recurring booking
  def transactable
    @transactable_drop ||= @recurring_booking.transactable.to_liquid
  end

  # @return [LocationDrop] LocationDrop object from the location associated with
  #   this recurring booking
  def location
    @location_drop ||= @recurring_booking.location.to_liquid
  end

  # @return [Boolean] whether there is a rejection reason for this recurring_booking
  def has_rejection_reason
    !rejection_reason.to_s.empty?
  end

  # @return [String] the search query URL for the same type of service as this recurring_booking and for this location
  # @todo Path/url inconsistency
  def search_url
    routes.search_path(q: location_query_string(@recurring_booking.transactable.location), transactable_type_id: @recurring_booking.transactable.transactable_type.id)
  end

  # @return [String] url to the dashboard area for managing own recurring_bookings
  # @todo Path/url inconsistency
  def bookings_dashboard_url
    routes.dashboard_user_recurring_bookings_path(token_key => @recurring_booking.owner.temporary_token)
  end

  # @return [String] url to the dashboard area showing a list of recurring bookings to be managed including this one;
  #   it takes the user to the correct area in the dashboard according to the state of the order (confirmed, unconfirmed,
  #   overdued, archived etc.)
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
  # @todo Path/url inconsistency
  def bookings_dashboard_url_with_tracking
    routes.dashboard_user_recurring_bookings_path(token_key => @recurring_booking.owner.temporary_token)
  end

  # @return [String] reservation starting date formatted information
  def dates_summary_with_hr
    "#{I18n.t('recurring_reservations_review.starts_from')} #{I18n.l(@recurring_booking.starts_at.to_date, format: :short)}"
  end

  # @return [String] url to the dashboard area for managing received bookings
  # @todo Path/url inconsistency
  def manage_guests_dashboard_url
    routes.dashboard_company_host_recurring_bookings_path
  end

  # @return [ActiveSupport::TimeWithZone] date at which the reservation was created
  def created_at
    @recurring_booking.created_at
  end

  # @return [String] url for confirming the recurring booking
  # @todo Path/url inconsistency
  def reservation_confirm_url
    routes.confirm_dashboard_company_host_recurring_booking_path(@recurring_booking, listing_id: @recurring_booking.transactable, token_key => @recurring_booking.creator.try(:temporary_token))
  end

  # @return [String] url for confirming the recurring booking with tracking
  # @todo Path/url inconsistency
  def reservation_confirm_url_with_tracking
    routes.confirm_dashboard_company_host_recurring_booking_path(@recurring_booking, listing_id: @recurring_booking.transactable, token_key => @recurring_booking.creator.try(:temporary_token))
  end

  # @return [ActiveSupport::TimeWithZone] reservation date (first date)
  def start_date
    @recurring_booking.starts_at
  end

  # @return [String] string representing the plural of the item to be booked (e.g. desks, rooms etc.),
  #   pluralized, and taken from the translations (e.g. translation key of the form 'transactable_type.desk.name')
  def bookable_noun_plural
    transactable_type.translated_bookable_noun(4)
  end

  # @return [String] current state of the object (e.g. unconfirmed etc.) as a human readable string
  def state_to_string
    @recurring_booking.state.to_s.humanize
  end

  # @return [String] translated number of units and unit for booking using the translation key
  #   'dashboard.user_recurring_bookings.every_unit_price' (e.g. 'Every month price')
  def booking_units
    @recurring_booking.transactable_pricing.decorate.units_translation('dashboard.user_recurring_bookings.every_unit_price')
  end
end
