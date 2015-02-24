class Reservation::FixedPriceCalculator
  def initialize(reservation)
    @reservation = reservation
  end

  def price
    (listing.fixed_price * (@reservation.quantity)).to_money
  end

  def valid?
    true
  end

  private

  def listing
    @reservation.listing
  end

end

