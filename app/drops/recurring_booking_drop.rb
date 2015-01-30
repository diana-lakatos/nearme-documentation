class RecurringBookingDrop < BaseDrop
  include ReservationsHelper

  attr_reader :reservation
  delegate :quantity, :subtotal_price, :service_fee_guest, :total_price, :pending?, :listing, :state_to_string,
  :credit_cart_payment?, :paid, :rejection_reason, :owner, to: :reservation
  delegate :transactable_type, to: :listing
  delegate :bookable_noun, :bookable_noun_plural, to: :transactable_type

  def initialize(recurring_booking)
    @recurring_booking = recurring_booking.decorate
    @reservation = recurring_booking.reservations.first.decorate
  end

  def hourly_summary
    @reservation.hourly_summary_for_first_period
  end

  def dates_summary
    @reservation.selected_dates_summary(wrapper: :span)
  end

  def balance
    @reservation.formatted_balance
  end

  def has_rejection_reason
    !rejection_reason.to_s.empty?
  end

  def search_url
    routes.search_path(q: location_query_string(@reservation.listing.location), transactable_type_id: @reservation.transactable_type.id)
  end

  def bookings_dashboard_url
    routes.dashboard_user_reservations_path(:reservation_id => @reservation, :token => @reservation.owner.temporary_token)
  end

  def manage_guests_dashboard_url
    routes.dashboard_host_reservations_path
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

  def created_at
    @reservation.created_at.strftime("%A,%e %B")
  end

  def reservation_confirm_url
    routes.confirm_manage_listing_reservation_path(@reservation.listing, @reservation, :token => @reservation.listing.administrator.try(:temporary_token))
  end

  def reservation_confirm_url_with_tracking
    routes.confirm_manage_listing_reservation_path(@reservation.listing, @reservation, :token => @reservation.listing.administrator.try(:temporary_token), :track_email_event => true)
  end

  def start_date
    @reservation.date.strftime('%b %e')
  end
end
