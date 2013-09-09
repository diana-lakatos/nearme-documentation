class ReservationDrop < BaseDrop
  include ReservationsHelper

  def initialize(reservation)
    @reservation = reservation
  end

  def quantity
    @reservation.quantity
  end

  def hourly_summary
    hourly_summary_for_period(@reservation.periods.first)
  end

  def dates_summary
    selected_dates_summary(@reservation)
  end

  def subtotal_price
    reservation_subtotal_price(@reservation)
  end

  def service_fee
    reservation_service_fee(@reservation)
  end

  def total_price
    reservation_total_price(@reservation)
  end

  def pending?
    @reservation.pending?
  end

  def credit_cart_payment?
    @reservation.credit_card_payment?
  end

  def paid
    reservation_paid(@reservation)
  end

  def balance
    reservation_balance(@reservation)
  end

  def search_url
    routes.search_url(q: location_query_string(@reservation.listing.location))
  end

  def created_at
    @reservation.created_at.strftime("%A,%e %B")
  end

  def owner
    @reservation.owner
  end
end
