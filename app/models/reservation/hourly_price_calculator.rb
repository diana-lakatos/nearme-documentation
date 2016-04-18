class Reservation::HourlyPriceCalculator
  def initialize(reservation)
    @reservation = reservation
    @pricing = @reservation.transactable_pricing
  end

  def price
    # Price is for each day, hours reserved in day * hourly price * quantity
    @reservation.periods.map { |period|
      price_for_hours(period.hours) * @reservation.quantity
    }.sum.to_money
  end

  def valid?
    !@reservation.periods.empty? && @reservation.periods.all? { |p| p.hours > 0 && @reservation.minimum_booking_minutes <= p.minutes }
  end

  def unit_price
    @pricing.price
  end

  def price_for_hours(hours)
    prices = @pricing.try(:all_prices_for_unit)
    if prices
      block_size = prices.keys.sort.inject { |largest_block, block_days|
        largest_block = block_days if hours >= block_days
        largest_block
      }
      pricing = prices[block_size]
      price = pricing[:price]

      if @reservation.favourable_pricing_rate || hours < block_size
        (((hours/block_size.to_f) * price.cents).round / BigDecimal.new(price.currency.subunit_to_unit)).to_money(price.currency)
      else
        priced_hours = hours/block_size
        left_hours = hours - priced_hours * block_size
        calculated_price = ((priced_hours * price.cents).round / BigDecimal.new(price.currency.subunit_to_unit)).to_money(price.currency)
        if left_hours.zero?
          calculated_price
        else
          calculated_price + price_for_days(left_hours)
        end
      end
    end
  end

  private

  def listing
    @reservation.listing
  end

end

