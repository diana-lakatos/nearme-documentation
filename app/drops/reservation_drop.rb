class ReservationDrop < BaseDrop
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
  # listing
  #   listing object for which this reservation has been made
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
  delegate :id, :quantity, :subtotal_price, :service_fee_guest, :total_price, :total_price_cents, :pending?, :listing, :state_to_string,
  :credit_card_payment?, :location, :paid, :rejection_reason, :owner, :action_hourly_booking?, :guest_notes, :created_at, 
  :total_payable_to_host_formatted, to: :reservation

  # bookable_noun
  #   string representing the object to be booked (e.g. desk, room etc.)
  # bookable_noun_plural
  #   string representing the object (plural) to be booked (e.g. desks, rooms etc.)
  delegate :bookable_noun, :bookable_noun_plural, to: :transactable_type_drop

  def initialize(reservation)
    @reservation = reservation.decorate
  end

  # the listing for which this reservation has been made
  def transactable_type
    @transactable_type ||= (@reservation.listing || Transactable.with_deleted.find(@reservation.transactable_id)).transactable_type
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
    routes.dashboard_user_reservations_path(:reservation_id => @reservation, token_key => @reservation.owner.temporary_token)
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
    routes.confirm_dashboard_company_host_reservation_path(@reservation, token_key => @reservation.listing.administrator.try(:temporary_token))
  end

  # url for confirming the recurring booking with tracking
  def reservation_confirm_url_with_tracking
    routes.confirm_dashboard_company_host_reservation_path(@reservation, token_key => @reservation.listing.administrator.try(:temporary_token), track_email_event: true)
  end

  # reservation date (first date)
  def start_date
    @reservation.date.to_date
  end

  # url to the reviews section in the user's dashboard
  def reviews_reservation_url
    routes.dashboard_reviews_path
  end

  def transactable_type_drop
    transactable_type.to_liquid
  end
end
