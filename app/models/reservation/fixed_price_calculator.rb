class Reservation::FixedPriceCalculator
  def initialize(reservation)
    @reservation = reservation
    @pricing = @reservation.transactable_pricing
  end

  def price
    if @reservation.book_it_out_discount
      (@pricing.price * @reservation.quantity * (1 - @reservation.book_it_out_discount / BigDecimal(100))).to_money
    elsif @reservation.exclusive_price_cents
      @reservation.exclusive_price
    else
      if @pricing.is_free_booking?
        0.to_money
      else
        (@pricing.price.to_f * (@reservation.quantity)).to_money
      end
    end
  end

  def valid?
    true
  end

  def unit_price
    @pricing.price
  end

  private

  def listing
    @reservation.listing
  end

end

