class Reservation::FixedPriceCalculator
  def initialize(reservation)
    @reservation = reservation
  end

  def price
    if @reservation.book_it_out_discount
      (listing.fixed_price * @reservation.quantity * (1 - @reservation.book_it_out_discount / BigDecimal(100))).to_money
    elsif @reservation.exclusive_price_cents
      @reservation.exclusive_price
    else
      if listing.action_free_booking?
        0.to_money
      else
        (listing.fixed_price.to_f * (@reservation.quantity)).to_money
      end
    end
  end

  def valid?
    true
  end

  private

  def listing
    @reservation.listing
  end

end

