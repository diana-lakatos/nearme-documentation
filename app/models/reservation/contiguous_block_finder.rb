class Reservation::ContiguousBlockFinder
  def initialize(reservation)
    @reservation = reservation
  end

  # Return an array where each element is an array of contiguous booked
  # days
  def contiguous_blocks
    dates = @reservation.periods.map(&:date).sort

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

  private

  def listing
    @reservation.listing
  end

  # Are to dates deemed "contiguous" by our custom definition?
  # That is, are they separated only by dates that are not bookable
  # due to availability rules.
  def contiguous?(from, to)
    return false if to < from

    while from < to
      from = from.advance(:days => 1)

      # Break if we reach a bookable date
      break if listing.open_on?(from) && listing.availability_for(from) >= @reservation.quantity
    end

    return from == to
  end
end
