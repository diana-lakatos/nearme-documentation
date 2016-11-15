# frozen_string_literal: true
class ReservationDrop < OrderDrop
  include ReservationsHelper

  attr_reader :reservation

  # quantity
  #   number of reserved items
  # subtotal_price
  #   subtotal amount as a string in a humanized format
  # service_fee_guest
  #   service fee guest in a humanized format
  # total_price
  #   total price in a humanized format
  # pending?
  #   returns true if the payment status is 'pending'
  # transactable
  #   transactable object for which this reservation has been made
  # state_to_string
  #   current state of the object in a humanized format as a string
  # credit_card_payment?
  #   returns true if a credit card has been used to make the purchase
  # location
  #   location object for which this reservation has been made
  # paid
  #   returns true if the current state of the payment is 'paid' (done)
  # rejection_reason
  #   returns the rejection reason for this reservation
  # owner
  #   returns the user object representing the person who has made this reservation
  # action_hourly_booking?
  #   returns true if hourly booking is available
  # guest_notes
  #   guest notes for this reservation as a string
  # total_payable_to_host_formatted
  #   total amount payable to host formatted as a string with currency symbol and cents
  # total_units_text
  #   Returns number of days/nights
  # additional_charges
  #   Returns array with additional charges
  # address
  #   Returns address associated with this reservation
  delegate :id, :quantity, :subtotal_price, :service_fee_guest, :total_price, :total_price_cents, :pending?, :transactable, :state_to_string,
           :credit_card_payment?, :location, :paid, :rejection_reason, :owner, :action_hourly_booking?, :guest_notes, :created_at,
           :total_payable_to_host_formatted, :total_units_text, :unit_price, :has_service_fee?, :transactable_line_items,
           :properties, :long_dates, :address, :periods, :comment, :cancellation_policy_penalty_hours, :tax_price,
           :manage_booking_status_info, :manage_booking_status_info_new, :lister_confirmed_at, :enquirer_confirmed_at,
           to: :reservation

  # bookable_noun
  #   string representing the object to be booked (e.g. desk, room etc.)
  # bookable_noun_plural
  #   string representing the object (plural) to be booked (e.g. desks, rooms etc.)
  delegate :bookable_noun, :bookable_noun_plural, to: :transactable_type_drop

  def initialize(reservation)
    @source = @order = @reservation = reservation.decorate
  end

  def additional_charges
    @reservation.additional_line_items
  end

  # the transactable for which this reservation has been made
  def transactable_type
    @transactable_type ||= (@reservation.transactable || Transactable.with_deleted.find(@reservation.transactable_id)).transactable_type
  end

  def formatted_unit_price
    render_money(unit_price)
  end

  # Hourly summary as string for the first booked period
  def hourly_summary
    @reservation.hourly_summary_for_first_period
  end

  # Summary as a string for the selected (booked) dates
  def dates_summary
    @reservation.selected_dates_summary(wrapper: :span)
  end

  # reservation dates separated with <hr>
  def dates_summary_with_hr
    @reservation.selected_dates_summary(separator: "<hr class='thin' />")
  end

  # total amount of reservation
  def total_amount_float
    @reservation.total_amount.to_f
  end

  # returns the difference between the paid sum and the total sum
  # formatted as a string (including currency etc.)
  def balance
    @reservation.formatted_balance
  end

  # returns true if there is a rejection reason for this reservation
  def has_rejection_reason
    !rejection_reason.to_s.empty?
  end

  # returns the search query URL for the same type of service as this reservation and for this location
  def search_url
    routes.search_path(q: location_query_string(@reservation.transactable.location), transactable_type_id: @reservation.transactable_type.id)
  end

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

  def guest_show_url
    path = if @reservation.archived_at.present?
             'archived_dashboard_user_reservations_url'
           else
             'upcoming_dashboard_user_reservations_url'
    end
    routes.send(path, anchor: "reservation_#{@reservation.id}", host: PlatformContext.current.decorate.host, token_key => @reservation.owner.temporary_token)
  end

  # url to the dashboard area for managing own reservations
  def bookings_dashboard_url
    routes.dashboard_user_reservations_path(reservation_id: @reservation, token_key => @reservation.owner.temporary_token)
  end

  # url to the dashboard area for managing received bookings
  def manage_guests_dashboard_url
    routes.dashboard_company_host_reservations_path
  end

  def export_to_ical_url
    routes.export_reservation_path(@reservation, format: :ics, token_key => @reservation.owner.try(:temporary_token))
  end

  def remote_payment_url
    routes.remote_payment_dashboard_user_reservation_path(@reservation, token_key => @reservation.owner.try(:temporary_token))
  end

  # url for confirming the recurring booking
  def reservation_confirm_url
    routes.confirm_dashboard_company_host_reservation_path(@reservation, token_key => @reservation.transactable.administrator.try(:temporary_token))
  end

  # url for confirming the recurring booking with tracking
  def reservation_confirm_url_with_tracking
    routes.confirm_dashboard_company_host_reservation_path(@reservation, token_key => @reservation.transactable.administrator.try(:temporary_token))
  end

  # url to the reviews section in the user's dashboard
  def reviews_reservation_url
    routes.dashboard_reviews_path
  end

  def transactable_type_drop
    transactable_type.to_liquid
  end

  # reservations currency
  def currency
    @reservation.total_amount.currency.symbol
  end

  def hourly_summary_if_available
    if @reservation.periods.first.read_attribute(:start_minute).present?
      reservation_period = @reservation.periods.first.decorate
      reservation_period.hourly_summary(false).html_safe
    else
      I18n.t('dashboard.user_reservations.not_available_na')
    end
  end

  # reservation date (first date)
  # QUESTION: do we need this method in that form? see next method with proper time-zone
  def start_date
    @reservation.starts_at
  end

  def starts_at
    @reservation.starts_at.in_time_zone(@reservation.transactable.timezone)
  end

  def total_amount_if_payment_at_least_authorized
    if @reservation.payment.pending? && !@reservation.has_to_update_credit_card?
      I18n.t('dashboard.user_reservations.total_amount_to_be_determined')
    else
      "<strong>#{@reservation.total_price}</strong>"
    end
  end

  def total_amount_for_host_if_payment_at_least_authorized
    if @reservation.payment.pending? && !@reservation.has_to_update_credit_card?
      I18n.t('dashboard.user_reservations.total_amount_to_be_determined')
    else
      "<strong>#{@reservation.total_payable_to_host_formatted}</strong>"
    end
  end

  # user message path
  def user_message_path
    routes.new_reservation_user_message_path(@reservation)
  end

  # owner including deleted ones
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
