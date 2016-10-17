# frozen_string_literal: true
class ReservationDrop < OrderDrop
  include ReservationsHelper

  # @return [Reservation]
  attr_reader :reservation

  # @!method id
  #   @return [Integer] numeric identifier for the reservation
  # @!method quantity
  #   Number of reserved items
  #   @return (see Order#quantity)
  # @!method subtotal_price
  #   @return (see ReservationDecorator#subtotal_price)
  # @!method service_fee_guest
  #   @return (see ReservationDecorator#service_fee_guest)
  # @!method total_price
  #   @return (see ReservationDecorator#total_price)
  # @!method transactable
  #   Transactable object associated with this order
  #   @return (see Order#transactable)
  # @!method state_to_string
  #   @return (see ReservationDecorator#state_to_string)
  # @!method location
  #   @return [Location] location to which the associated transactable belongs
  # @!method paid
  #   @return (see ReservationDecorator#paid)
  # @!method rejection_reason
  #   Rejection reason for this reservation if present
  #   @return (see Order#rejection_reason)
  # @!method owner
  #   User owner of the reservation
  #   @return (see Order#owner)
  # @!method action_hourly_booking?
  #   @return (see Reservation#action_hourly_booking?)
  # @!method guest_notes
  #   @return (see Order#guest_notes)
  # @!method created_at
  #   @return [ActiveSupport::TimeWithZone] time when the reservation process was initiated
  # @!method total_payable_to_host_formatted
  #   @return (see ReservationDecorator#total_payable_to_host_formatted)
  # @!method total_units_text
  #   @return (see ReservationDecorator#total_units_text)
  # @!method unit_price
  #   @return [Money] unit price for the reservation
  # @!method has_service_fee?
  #   @return [Boolean] whether the reservation includes a service fee
  # @!method transactable_line_items
  #   @return [Array<LineItem::Transactable>] array of line items for this order (reservation)
  # @!method properties
  #   @return [CustomAttributes::CollectionProxy] collection of properties for this reservation
  # @!method long_dates
  #   @return (see ReservationDecorator#long_dates)
  # @!method address
  #   @return [Address] address object associated with this order (reservation)
  # @!method periods
  #   Reservation periods associated with this order
  #   @return (see Order#periods)
  # @!method comment
  #   Comment associated with this order
  #   @return (see Order#comment)
  # @!method cancellation_policy_penalty_hours
  #   Used for calculating the penalty for cancelling (unit_price * cancellation_policy_penalty_hours)
  #   @return (see Order#cancellation_policy_penalty_hours)
  # @!method tax_price
  #   @return (see ReservationDecorator#tax_price)
  # @!method manage_booking_status_info
  #   @return (see ReservationDecorator#manage_booking_status_info)
  # @!method manage_booking_status_info_new
  #   @return (see ReservationDecorator#manage_booking_status_info_new)
  # @!method lister_confirmed_at
  #   Time when the lister confirmed the reservation
  #   @return (see Order#lister_confirmed_at)
  # @!method enquirer_confirmed_at
  #   Time when the enquirer (buyer) confirmed the reservation
  #   @return (see Order#enquirer_confirmed_at)
  delegate :id, :quantity, :subtotal_price, :service_fee_guest, :total_price, :transactable, :state_to_string,
           :location, :paid, :rejection_reason, :owner, :action_hourly_booking?, :guest_notes, :created_at,
           :total_payable_to_host_formatted, :total_units_text, :unit_price, :has_service_fee?, :transactable_line_items,
           :properties, :long_dates, :address, :periods, :comment, :cancellation_policy_penalty_hours, :tax_price,
           :manage_booking_status_info, :manage_booking_status_info_new, :lister_confirmed_at, :enquirer_confirmed_at,
           to: :reservation

  # bookable_noun
  #   string representing the object to be booked (e.g. desk, room etc.)
  # bookable_noun_plural
  #   string representing the object (plural) to be booked (e.g. desks, rooms etc.)

  # @!method bookable_noun
  #   @return (see TransactableTypeDrop#bookable_noun)
  # @!method bookable_noun_plural
  #   @return (see TransactableTypeDrop#bookable_noun_plural)
  delegate :bookable_noun, :bookable_noun_plural, to: :transactable_type_drop

  def initialize(reservation)
    @source = @order = @reservation = reservation.decorate
  end

  # @return [Array<LineItem::Additional] array of additional charges for this reservation
  def additional_charges
    @reservation.additional_line_items
  end

  # @return [TransactableType] the transactable type for which this reservation has been made
  def transactable_type
    @transactable_type ||= (@reservation.transactable || Transactable.with_deleted.find(@reservation.transactable_id)).transactable_type
  end

  # @return [String] unit price for the reservation formatted using the global currency
  #   formatting rules 
  def formatted_unit_price
    render_money(unit_price)
  end

  # @return [String] hourly summary as string for the first booked period
  def hourly_summary
    @reservation.hourly_summary_for_first_period
  end

  # @return [String] summary as a string for the selected (booked) dates
  def dates_summary
    @reservation.selected_dates_summary(wrapper: :span)
  end

  # @return [String] reservation dates separated with <hr>
  def dates_summary_with_hr
    @reservation.selected_dates_summary(separator: "<hr class='thin' />")
  end

  # @return [Float] total amount of reservation
  def total_amount_float
    @reservation.total_amount.to_f
  end

  # @todo Not working - investigate and remove
  def balance
    @reservation.formatted_balance
  end

  # @return [Boolean] whether there is a rejection reason for this reservation
  def has_rejection_reason
    !rejection_reason.to_s.empty?
  end

  # @return [String] the search query URL for the same type of service as this reservation and for this location
  def search_url
    routes.search_path(q: location_query_string(@reservation.transactable.location), transactable_type_id: @reservation.transactable_type.id)
  end

  # @return [String] url to the dashboard area for managing received reservations; leads to the section in the
  #   dashboard where this reservation can be found (i.e. archived/confirmed/unconfirmed/etc. section)
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
  def guest_show_url
    path = if @reservation.archived_at.present?
             'archived_dashboard_user_reservations_url'
           else
             'upcoming_dashboard_user_reservations_url'
    end
    routes.send(path, anchor: "reservation_#{@reservation.id}", host: PlatformContext.current.decorate.host, token_key => @reservation.owner.temporary_token)
  end

  # @return [String] url to the dashboard area for managing own reservations
  # @todo Path/url inconsistency
  def bookings_dashboard_url
    routes.dashboard_user_reservations_path(reservation_id: @reservation, token_key => @reservation.owner.temporary_token)
  end

  # @return [String] url to the dashboard area for managing received bookings
  # @todo Path/url inconsistency
  def manage_guests_dashboard_url
    routes.dashboard_company_host_reservations_path
  end

  # @return [String] url to export the reservation to an ical file
  # @todo Path/url inconsistency
  def export_to_ical_url
    routes.export_reservation_path(@reservation, format: :ics, token_key => @reservation.owner.try(:temporary_token))
  end

  # @return [String] url where the user can repeat the payment process if payment is missing for the reservation
  def remote_payment_url
    routes.remote_payment_dashboard_user_reservation_path(@reservation, token_key => @reservation.owner.try(:temporary_token))
  end

  # @return [String] url for confirming the reservation
  def reservation_confirm_url
    routes.confirm_dashboard_company_host_reservation_path(@reservation, token_key => @reservation.transactable.administrator.try(:temporary_token))
  end

  # @return [String] url for confirming the reservation with tracking
  def reservation_confirm_url_with_tracking
    routes.confirm_dashboard_company_host_reservation_path(@reservation, token_key => @reservation.transactable.administrator.try(:temporary_token))
  end

  # @return [String] url to the reviews section in the user's dashboard
  def reviews_reservation_url
    routes.dashboard_reviews_path
  end

  # @return [TransactableTypeDrop] TransactableTypeDrop object for this reservation's associated {TransactableType}
  def transactable_type_drop
    transactable_type.to_liquid
  end

  # @return [String] reservation's currency
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

  # @return [ActiveSupport::TimeWithZone] reservation date/time (first date)
  # @todo: QUESTION: do we need this method in that form? see next method with proper time-zone
  def start_date
    @reservation.starts_at
  end

  # @return [ActiveSupport::TimeWithZone] reservation date/time (first date) in
  #   the timezone of the associated transactable object
  def starts_at
    @reservation.starts_at.in_time_zone(@reservation.transactable.timezone)
  end

  # @return [String] if the payment is pending and the user doesn't need to
  #   update his credit card, the translated string 'dashboard.user_reservations.total_amount_to_be_determined'
  #   will be returned, otherwise, the HTML-formatted total price will be returned
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
  def total_amount_for_host_if_payment_at_least_authorized
    if @reservation.payment.pending? && !@reservation.has_to_update_credit_card?
      I18n.t('dashboard.user_reservations.total_amount_to_be_determined')
    else
      "<strong>#{@reservation.total_payable_to_host_formatted}</strong>"
    end
  end

  # @return [String] new user message path (for discussion between lister and enquirer)
  def user_message_path
    routes.new_reservation_user_message_path(@reservation)
  end

  # @return [User] owner of the reservation (buyer) including deleted ones
  def owner_including_deleted
    User.unscoped { @reservation.owner }
  end

  # SHIPPING

  # shipping package name and description if applicable
  def shipping_package
    reservation.transactable.dimensions_template
  end

  # QUESTION: how to call drop method from parent drop
  def enquirer_shipping_address
    reservation.shipping_address.address
  end
end
