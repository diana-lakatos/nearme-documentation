# encoding: utf-8
#
# Object encapsulating our pricing calculation logic.
# Pass it a reservation, and let it do its thing.
#
# NB: Note that there is a corresponding JS calculation class
#     to calculate the price client-side. If logic changes,
#     be sure to update that as well.
class Reservation::DailyPriceCalculator
  attr_reader :reservation

  def initialize(reservation)
    @reservation = reservation
    @contiguous_block_finder = Reservation::ContiguousBlockFinder.new(reservation)
  end

  # Returns the total price for the listing and it's chosen
  # periods. Returns nil if the selection is unbookable
  def price
    contiguous_blocks.map do |block|
      price_for_days(block.size) * @reservation.quantity rescue 0.0
    end.sum.to_money
  end

  # Returns true if the selection of dates are valid in terms of the pricing
  # method. Depending on the pricing method, certain selections of dates may
  # not be bookable (i.e. 1 day is unbookable for a listing that requires
  # minimum of 5 days).
  def valid?
    listing && !contiguous_blocks.empty? && contiguous_blocks.all? { |block|
      block.length >= listing.minimum_booking_days
    }
  end

  private

  # Price for contiguous days in as a Money object
  def price_for_days(days)
    prices = listing.try(:prices_by_days)

    if prices
      # Determine the matching block size and price
      block_size = prices.keys.sort.inject { |largest_block, block_days|
        largest_block = block_days if days >= block_days
        largest_block
      }
      price = prices[block_size]

      # Our pricing logic per block is the block price
      # plus a pro-rated cost for each additional day used
      (((days/block_size.to_f) * price.cents).round / 100.0).to_money
    end
  end

  def listing
    @reservation.listing
  end

  def contiguous_blocks
    @contiguous_block_finder.contiguous_blocks
  end

end
