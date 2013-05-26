# encoding: utf-8
#
# Object encapsulating our pricing calculation logic.
# Pass it a reservation, and let it do its thing.
# 
# NB: Note that there is a corresponding JS calculation class
#     to calculate the price client-side. If logic changes, 
#     be sure to update that as well.
class Reservation::PriceCalculator
  def initialize(reservation)
    @reservation = reservation
    @contiguous_block_finder = Reservation::ContiguousBlockFinder.new(reservation)
  end

  def price
    @contiguous_block_finder.contiguous_blocks.map { |block|
      price_for_days(block.size) * @reservation.quantity
    }.sum.to_money
  end

  # Price for contiguous days in as a Money object
  def price_for_days(days)
    prices = listing.prices_by_days

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

  private

  def listing
    @reservation.listing
  end

end
