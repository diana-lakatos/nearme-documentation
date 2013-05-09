# encoding: utf-8
#
# Object encapsulating our pricing calculation logic.
# Pass it a reservation, and let it do its thing.
#
# NB: Note that there is a corresponding JS calculation class
#     to calculate the price client-side. If logic changes,
#     be sure to update that as well.
class Reservation::PriceCalculator
  attr_reader :reservation

  def initialize(reservation)
    @reservation = reservation
  end

  # Returns the total price for the listing and it's chosen
  # periods. Returns nil if the selection is unbookable
  def price
    contiguous_blocks.map { |block|
      price_for_days(block.size) * reservation.quantity
    }.sum.to_money if valid?
  end

  # Returns true if the selection of dates are valid in terms of the pricing
  # method. Depending on the pricing method, certain selections of dates may
  # not be bookable (i.e. 1 day is unbookable for a listing that requires
  # minimum of 5 days).
  def valid?
    !contiguous_blocks.empty? && contiguous_blocks.all? { |block|
      block.length >= listing.minimum_booking_days
    }
  end

  private

  def listing
    @reservation.listing
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

  # Return an array where each element is an array of contiguous booked
  # days
  def contiguous_blocks
    dates = reservation.periods.map(&:date).sort

    # Hash of block start date to array of dates in the contiguous
    # block
    blocks = Hash.new { |hash, key| hash[key] = [] }

    current_start, previous_date = nil, nil
    dates.each do |date|
      if !previous_date || !contiguous?(previous_date, date)
        current_start = date
      end

      blocks[current_start] << date
      previous_date = date
    end

    blocks.values
  end

  # Are to dates deemed "contiguous" by our custom definition?
  # That is, are they separated only by dates that are not bookable
  # due to availability rules.
  def contiguous?(from, to)
    return false if to < from

    while from < to
      from = from.advance(:days => 1)

      # Break if we reach a bookable date
      break if listing.open_on?(from) && listing.availability_for(from) >= reservation.quantity
    end

    return from == to
  end
end
