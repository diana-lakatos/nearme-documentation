class ReservationDrop < BaseDrop
  include ReservationsHelper

  attr_reader :reservation
  delegate :quantity, :subtotal_price, :service_fee_guest, :total_price, :pending?, :listing, :state_to_string,
  :credit_cart_payment?, :location, :paid, :rejection_reason, :owner, :action_hourly_booking?, to: :reservation
  delegate :transactable_type, to: :listing
  delegate :bookable_noun, :bookable_noun_plural, to: :transactable_type

  def initialize(reservation)
    @reservation = reservation.decorate
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
    routes.dashboard_company_host_reservations_path
  end

  def export_to_ical_url
    routes.export_reservation_path(@reservation, format: :ics, token: @reservation.owner.try(:temporary_token))
  end

  def remote_payment_url
    routes.remote_payment_dashboard_user_reservation_path(@reservation, token: @reservation.owner.try(:temporary_token))
  end

  def created_at
    @reservation.created_at.strftime("%A,%e %B")
  end

  def reservation_confirm_url
    routes.confirm_dashboard_company_host_reservation_path(@reservation, token: @reservation.listing.administrator.try(:temporary_token))
  end

  def reservation_confirm_url_with_tracking
    routes.confirm_dashboard_company_host_reservation_path(@reservation, token: @reservation.listing.administrator.try(:temporary_token), track_email_event: true)
  end

  def start_date
    @reservation.date.strftime('%b %e')
  end

  def reviews_reservation_url
    routes.dashboard_reviews_path
  end
end
