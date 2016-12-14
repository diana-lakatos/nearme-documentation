# frozen_string_literal: true
class ReservationDrop < OrderDrop
  include ReservationsHelper

  # @return [ReservationDrop]
  attr_reader :reservation

  # @!method id
  #   @return [Integer] numeric identifier for the reservation
  # @!method quantity
  #   @return [Integer] Number of reserved items
  # @!method subtotal_price
  #   @return [String] subtotal price formatted using the global currency formatting rules
  #     or 'Free!' if free
  # @!method service_fee_guest
  #   @return [String] service fee (guest part) formatted using the global currency formatting
  #     rules or 'Free!' if free
  # @!method total_price
  #   @return [String] total price formatted using the global currency formatting rules
  #     or 'Free!' if free
  # @!method transactable
  #   @return [TransactableDrop] Transactable object associated with this order
  # @!method state_to_string
  #   @return [String] state of the reservation in a human readable format
  # @!method location
  #   @return [LocationDrop] location to which the associated transactable belongs
  # @!method paid
  #   @return [String] amount paid for this reservation formatted using the global currency
  #     formatting rules or the current state of the payment if not yet paid
  # @!method rejection_reason
  #   @return [String] Rejection reason for this reservation if present
  # @!method owner
  #   @return [UserDrop] User owner of the reservation
  # @!method action_hourly_booking?
  #   @return [Boolean] whether hourly booking is available for this reservation
  # @!method guest_notes
  #   @return [String] guest notes left for the order
  # @!method created_at
  #   @return [DateTime] time when the reservation process was initiated
  # @!method total_payable_to_host_formatted
  #   @return [String] total amount payable to host formatted using the global currency
  #     formatting rules
  # @!method total_units_text
  #   @return [String] total units text (e.g. "1 day", "3 nights")
  # @!method unit_price
  #   @return [MoneyDrop] unit price for the reservation
  # @!method has_service_fee?
  #   @return [Boolean] whether the reservation includes a service fee
  # @!method transactable_line_items
  #   @return [Array<LineItemDrop>] array of line items for this order (reservation)
  # @!method properties
  #   @return [Hash] collection of properties for this reservation
  # @!method long_dates
  #   @return [String] summary of selected dates for this reservation
  # @!method address
  #   @return [AddressDrop] address object associated with this order (reservation)
  # @!method periods
  #   @return [Array<ReservationPeriod>] Reservation periods associated with this order
  # @!method comment
  #   @return [String] Comment associated with this order
  # @!method cancellation_policy_penalty_hours
  #   @return [Integer] Used for calculating the penalty for cancelling (unit_price * cancellation_policy_penalty_hours)
  # @!method tax_price
  #   @return [String] total tax amount for this reservation formatted using the global
  #     currency formatting rules
  # @!method manage_booking_status_info
  #   @return [String] formatted string instructing the user to confirm their booking before expiration if unconfirmed, otherwise
  #     renders an icon with the status information
  # @!method manage_booking_status_info_new
  #   @return [String] formatted string instructing the user to confirm their booking before expiration
  #     using the translation key 'dashboard.host_reservations.pending_confirmation'
  # @!method lister_confirmed_at
  #   @return [DateTime] Time when the lister confirmed the reservation
  # @!method enquirer_confirmed_at
  #   @return [DateTime] Time when the enquirer (buyer) confirmed the reservation
  delegate :id, :quantity, :subtotal_price, :service_fee_guest, :total_price, :transactable, :state_to_string,
           :location, :paid, :rejection_reason, :owner, :action_hourly_booking?, :guest_notes, :created_at,
           :total_payable_to_host_formatted, :total_units_text, :unit_price, :has_service_fee?, :transactable_line_items,
           :properties, :long_dates, :address, :periods, :comment, :cancellation_policy_penalty_hours, :tax_price,
           :manage_booking_status_info, :manage_booking_status_info_new, :lister_confirmed_at, :enquirer_confirmed_at,
           to: :reservation

  # @!method bookable_noun
  #   @return see TransactableTypeDrop#bookable_noun
  # @!method bookable_noun_plural
  #   @return see TransactableTypeDrop#bookable_noun_plural
  delegate :bookable_noun, :bookable_noun_plural, to: :transactable_type_drop

  def initialize(reservation)
    @source = @order = @reservation = reservation.decorate
  end

  # @return [Array<LineItemDrop>] array of additional charges for this reservation
  def additional_charges
    @reservation.additional_line_items
  end

  # @return [TransactableTypeDrop] the transactable type for which this reservation has been made
  # @todo - just a code smell
  def transactable_type
    @transactable_type ||= (@reservation.transactable || Transactable.with_deleted.find(@reservation.transactable_id)).transactable_type
  end

  # @return [String] unit price for the reservation formatted using the global currency
  #   formatting rules
  # @todo -- investigate if unit filter can be used
  def formatted_unit_price
    render_money(unit_price)
  end

  # @return [String] hourly summary as string for the first booked period
  # @todo -- depracate per DIY -- lets not return strings - also, underlying methods are smelly
  def hourly_summary
    @reservation.hourly_summary_for_first_period
  end

  # @return [String] summary as a string for the selected (booked) dates
  # @todo -- depracate per DIY -- lets not return strings (wrapped in html) - also, underlying methods are smelly
  def dates_summary
    @reservation.selected_dates_summary(wrapper: :span)
  end

  # @return [String] reservation dates separated with <hr>
  # @todo -- depracate per DIY
  def dates_summary_with_hr
    @reservation.selected_dates_summary(separator: "<hr class='thin' />")
  end

  # @return [Float] total amount of reservation
  # @todo -- investigate if unit filter can be used and/or rename
  def total_amount_float
    @reservation.total_amount.to_f
  end

  # @return [Boolean] whether there is a rejection reason for this reservation
  # @todo -- again, we shouldnt provide such specific methods in DIY
  def has_rejection_reason
    !rejection_reason.to_s.empty?
  end

  # @return [String] the search query URL for the same type of service as this reservation and for this location
  # @todo -- depracate in favor of filter
  def search_url
    routes.search_path(q: location_query_string(@reservation.transactable.location), transactable_type_id: @reservation.transactable_type.id)
  end

  # @return [String] url to the dashboard area for managing received reservations; leads to the section in the
  #   dashboard where this reservation can be found (i.e. archived/confirmed/unconfirmed/etc. section)
  # @todo -- depracate in favor of filter
  def host_show_url
    state = if @reservation.archived_at.present?
              'archived'
            elsif @reservation.confirmed?
              'confirmed'
            elsif @reservation.unconfirmed?
              'unconfirmed'
            end
    routes.dashboard_company_host_reservations_url(state: state, anchor: "reservation_#{@reservation.id}", host: PlatformContext.current.decorate.host, token_key => @reservation.transactable.creator.temporary_token)
  end

  # @return [String] url to the dashboard area for managing placed reservations; leads to the section in the
  #   dashboard where this reservation can be found (i.e. archived/upcoming/etc. section)
  # @todo -- depracate in favor of filter
  def guest_show_url
    path = if @reservation.archived_at.present?
             'archived_dashboard_user_reservations_url'
           else
             'upcoming_dashboard_user_reservations_url'
    end
    routes.send(path, anchor: "reservation_#{@reservation.id}", host: PlatformContext.current.decorate.host, token_key => @reservation.owner.temporary_token)
  end

  # @return [String] url to the dashboard area for managing own reservations
  # @todo -- depracate in favor of filter
  def bookings_dashboard_url
    routes.dashboard_user_reservations_path(reservation_id: @reservation, token_key => @reservation.owner.temporary_token)
  end

  # @return [String] url to the dashboard area for managing received bookings
  # @todo -- depracate in favor of filter
  def manage_guests_dashboard_url
    routes.dashboard_company_host_reservations_path
  end

  # @return [String] url to export the reservation to an ical file
  # @todo -- depracate in favor of filter
  def export_to_ical_url
    routes.export_reservation_path(@reservation, format: :ics, token_key => @reservation.owner.try(:temporary_token))
  end

  # @return [String] url where the user can repeat the payment process if payment is missing for the reservation
  # @todo -- depracate in favor of filter
  def remote_payment_url
    routes.remote_payment_dashboard_user_reservation_path(@reservation, token_key => @reservation.owner.try(:temporary_token))
  end

  # @return [String] url for confirming the reservation
  # @todo -- depracate in favor of filter
  def reservation_confirm_url
    routes.confirm_dashboard_company_host_reservation_path(@reservation, token_key => @reservation.transactable.administrator.try(:temporary_token))
  end

  # @return [String] url for confirming the reservation with tracking
  # @todo -- depracate in favor of filter
  def reservation_confirm_url_with_tracking
    routes.confirm_dashboard_company_host_reservation_path(@reservation, token_key => @reservation.transactable.administrator.try(:temporary_token))
  end

  # @return [String] url to the reviews section in the user's dashboard
  # @todo -- depracate in favor of filter
  def reviews_reservation_url
    routes.dashboard_reviews_path
  end

  # @return [TransactableTypeDrop] TransactableTypeDrop object for this reservation's associated TransactableType
  # @todo -- investigate if this is necessary
  def transactable_type_drop
    transactable_type.to_liquid
  end

  # @return [String] reservation's currency
  # @todo -- investigate if currency
  def currency
    @reservation.total_amount.currency.symbol
  end

  # @return [String] hourly summary for this reservation if available otherwise
  #   the translated string (key) 'dashboard.user_reservations.not_available_na'
  def hourly_summary_if_available
    if @reservation.periods.first.read_attribute(:start_minute).present?
      reservation_period = @reservation.periods.first.decorate
      reservation_period.hourly_summary(false).html_safe
    else
      I18n.t('dashboard.user_reservations.not_available_na')
    end
  end

  # @return [DateTime] reservation date/time (first date)
  # @todo: QUESTION: do we need this method in that form? see next method with proper time-zone
  def start_date
    @reservation.starts_at
  end

  # @return [DateTime] reservation date/time (first date) in
  #   the timezone of the associated transactable object
  # @todo -- again, maybe some general class of pulling out dates
  def starts_at
    @reservation.starts_at.in_time_zone(@reservation.transactable.timezone)
  end

  # @return [String] if the payment is pending and the user doesn't need to
  #   update his credit card, the translated string 'dashboard.user_reservations.total_amount_to_be_determined'
  #   will be returned, otherwise, the HTML-formatted total price will be returned
  # @todo -- we should not provide html in DIY approach at all. Also translations would be nice
  def total_amount_if_payment_at_least_authorized
    if @reservation.payment.pending? && !@reservation.has_to_update_credit_card?
      I18n.t('dashboard.user_reservations.total_amount_to_be_determined')
    else
      "<strong>#{@reservation.total_price}</strong>"
    end
  end

  # @return [String] if the payment is pending and the user doesn't need to update
  #   his credit card, the translated string 'dashboard.user_reservations.total_amount_to_be_determined'
  #   will be returned, otherwise, the HTML-formatted total amount payable to host
  #   is returned
  # @todo -- we should not provide html in DIY approach at all. Also translations would be nice
  def total_amount_for_host_if_payment_at_least_authorized
    if @reservation.payment.pending? && !@reservation.has_to_update_credit_card?
      I18n.t('dashboard.user_reservations.total_amount_to_be_determined')
    else
      "<strong>#{@reservation.total_payable_to_host_formatted}</strong>"
    end
  end

  # @return [String] new user message path (for discussion between lister and enquirer)
  # @todo -- depracate in favor of filter
  def user_message_path
    routes.new_reservation_user_message_path(@reservation)
  end

  # @return [UserDrop] owner of the reservation (buyer) including deleted ones
  # @todo -- change the behavior to always return all and add filter to filter out those that user doesnt want
  # in DIY of course user will pull only what he/she needs so it wont be needed at all
  def owner_including_deleted
    User.unscoped { @reservation.owner }
  end

  # SHIPPING

  # @return [DimensionsTemplateDrop] shipping package name and description if applicable
  def shipping_package
    reservation.dimensions_templates.last || reservation.transactable.dimensions_template
  end

  # @return [String] shipping address for the enquirer (buyer)
  def enquirer_shipping_address
    reservation.shipping_address.try(:address)
  end
end
