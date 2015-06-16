class RecurringBookingDrop < BaseDrop
  include ReservationsHelper

  attr_reader :reservation

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
  # state_to_string
  #   current state of the object (e.g. unconfirmed etc.) as a humanized string
  # credit_card_payment?
  #   returns true if the payment method for the reservation was credit card
  # paid
  #   returns the paid amount (if confirmed) otherwise returns the current state
  #   of the object
  # rejection_reason
  #   returns the reason as string for which the reservation has been rejected
  # owner
  #   user object containing the person who made the booking
  delegate :quantity, :subtotal_price, :service_fee_guest, :total_price, :pending?, :listing, :state_to_string,
  :credit_cart_payment?, :paid, :rejection_reason, :owner, to: :reservation

  # transactable_type
  #   the object describing the type of item to be booked (e.g. desk, room etc.)
  # action_hourly_booking?
  #   returns true if hourly booking is available for this listing
  delegate :transactable_type, :action_hourly_booking?, to: :listing

  # bookable_noun
  #   string representing the item to be booked (e.g. desk, room etc.)
  # bookable_noun_plural
  #   string representing the plural of the item to be booked (e.g. desks, rooms etc.)
  delegate :bookable_noun, :bookable_noun_plural, to: :transactable_type

  def initialize(recurring_booking)
    @recurring_booking = recurring_booking.decorate
    @reservation = recurring_booking.reservations.first.decorate
  end

  # Hourly summary as string for the first booked period
  def hourly_summary
    @reservation.hourly_summary_for_first_period
  end

  # Summary as a string for the selected (booked) dates
  def dates_summary
    @reservation.selected_dates_summary(wrapper: :span)
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
    routes.search_path(q: location_query_string(@reservation.listing.location), transactable_type_id: @reservation.transactable_type.id)
  end

  # url to the dashboard area for managing own reservations
  def bookings_dashboard_url
    routes.dashboard_user_reservations_path(:reservation_id => @reservation, :token => @reservation.owner.temporary_token)
  end

  # url to the dashboard area for managing received bookings
  def manage_guests_dashboard_url
    routes.dashboard_company_host_reservations_path
  end

  def guest_rating_reservation_url
    routes.guest_rating_path(@reservation.id, token: @reservation.listing.administrator.try(:temporary_token))
  end

  def guest_rating_reservation_url_with_tracking
    routes.guest_rating_path(@reservation.id, token: @reservation.listing.administrator.try(:temporary_token), track_email_event: true)
  end

  def host_rating_reservation_url
    routes.host_rating_path(@reservation.id, token: @reservation.owner.try(:temporary_token))
  end

  def host_rating_reservation_url_with_tracking
    routes.host_rating_path(@reservation.id, token: @reservation.owner.try(:temporary_token), track_email_event: true)
  end

  def export_to_ical_url
    routes.export_reservation_path(@reservation, format: :ics, token: @reservation.owner.try(:temporary_token))
  end

  def remote_payment_url
    routes.remote_payment_reservation_path(@reservation, token: @reservation.owner.try(:temporary_token))
  end

  # date at which the reservation was created formatted as a string
  def created_at
    @reservation.created_at.strftime("%A,%e %B")
  end

  # url for confirming the recurring booking
  def reservation_confirm_url
    routes.confirm_dashboard_host_recurring_booking_path(@reservation.listing, @reservation, :token => @reservation.listing.administrator.try(:temporary_token))
  end

  # url for confirming the recurring booking with tracking
  def reservation_confirm_url_with_tracking
    routes.confirm_dashboard_host_recurring_booking_path(@reservation.listing, @reservation, :token => @reservation.listing.administrator.try(:temporary_token), :track_email_event => true)
  end

  # reservation date (first date)
  def start_date
    @reservation.date.strftime('%b %e')
  end
end
