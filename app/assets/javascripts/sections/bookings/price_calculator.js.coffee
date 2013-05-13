# Object encapsulating our pricing calculation logic.
#
# NB: Note that there is a corresponding Ruby calculating class
#     to calculate the price server-side. If the logic changes,
#     be sure to update that as well.
class @Bookings.PriceCalculator

  constructor: (@listing) ->

  getPrice: ->
    _.inject(@contiguousBlocks(), (sum, block) =>
      sum + @priceForDays(block.length)*@listing.getQuantity()
    , 0)

  priceForDays: (days) ->
    prices = @listing.pricesByDays
    pricesDays = _.keys(prices)

    block_size = _.inject pricesDays, (largestBlock, blockDays) ->
      largestBlock = blockDays if days >= blockDays
      largestBlock

    price = prices[block_size]
    Math.round((days/block_size) * price)

  contiguousBlocks: ->
    dates = _.sortBy @listing.bookedDates(), (date) -> date.getTime()

    blocks = []
    current_block = null
    previous_date = null

    for date in dates
      # Every time we break a contiguous
      if !previous_date or !@isContiguous(previous_date, date)
        current_block = []
        blocks.push(current_block)

      current_block.push(date)
      previous_date = date

    blocks

  isContiguous: (from, to) ->
    return false if to.getTime() < from.getTime()

    while from.getTime() < to.getTime()
      from = DNM.util.Date.next(from)
      break if @listing.canBookDate(from)

    return DNM.util.Date.toId(from) == DNM.util.Date.toId(to)


  class @HourlyPriceCalculator
    constructor: (@listing) ->

    getPrice: ->
      bookedHours = (@minutesBooked()/60)*@listing.bookedDates().length
      @listing.hourlyPrice*bookedHours*@listing.getQuantity()

    minutesBooked: ->
      @listing.getEndMinute() - @listing.getStartMinute()

