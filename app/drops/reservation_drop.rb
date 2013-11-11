class ReservationDrop < BaseDrop
  include ReservationsHelper

  def initialize(reservation)
    @reservation = reservation.decorate
  end

  def quantity
    @reservation.quantity
  end

  def hourly_summary
    @reservation.hourly_summary_for_first_period
  end

  def dates_summary
    @reservation.selected_dates_summary
  end

  def subtotal_price
    @reservation.subtotal_price
  end

  def service_fee
    @reservation.service_fee
  end

  def total_price
    @reservation.total_price
  end

  def pending?
    @reservation.pending?
  end

  def credit_cart_payment?
    @reservation.credit_card_payment?
  end

  def paid
    @reservation.paid
  end

  def balance
    @reservation.formatted_balance
  end

  def has_rejection_reason
    !@reservation.rejection_reason.to_s.empty?
  end

  def rejection_reason
    @reservation.rejection_reason
  end

  def search_url
    routes.search_url(q: location_query_string(@reservation.listing.location))
  end

  def guest_rating_reservation_url
    routes.guest_rating_url(@reservation.id, token: @reservation.owner.authentication_token)
  end

  def host_rating_reservation_url
    routes.host_rating_url(@reservation.id, token: @reservation.listing.administrator.authentication_token)
  end

  def export_to_ical_url
    routes.export_reservation_url(@reservation, format: :ics, token: @reservation.owner.authentication_token)
  end

  def created_at
    @reservation.created_at.strftime("%A,%e %B")
  end

  def owner
    @reservation.owner
  end

  def reservation_confirm_url
    routes.confirm_manage_listing_reservation_url(@reservation.listing, @reservation, :token => @reservation.listing.creator.authentication_token)
  end 

  def start_date
    @reservation.date.strftime('%b %e')
  end
end
