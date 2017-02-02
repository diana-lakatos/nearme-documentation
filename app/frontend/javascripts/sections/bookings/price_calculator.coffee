AdditionalChargesCalculator = require('./additional_charges')
dateUtil = require('../../lib/utils/date')

# Object encapsulating our pricing calculation logic.
#
# NB: Note that there is a corresponding Ruby calculating class
#     to calculate the price server-side. If the logic changes,
#     be sure to update that as well.
module.exports = class BookingsPriceCalculator

  constructor: (@listing) ->
    @additionalCharges = new AdditionalChargesCalculator($("#additional-charges-#{@listing.id}"), @listing.data.subunit_to_unit_rate)

  getPrice: ->
    contiguousBlocks = @contiguousBlocks()

    total = _.inject(contiguousBlocks, (sum, block) =>
      block_length = block.length
      if @listing.isOvernightBooking() && block_length > 1
        block_length = block_length - 1
      sum + @priceForDays(block_length)*@listing.getQuantity()
    , 0)
    total += @additionalCharges.getCharges(total)
    if @pricing
      @listing.currentPricingId = @pricing.id
    total

  priceForDays: (days) ->
    prices = if @listing.isOvernightBooking() then @listing.pricesByNights else @listing.pricesByDays
    pricesDays = _.keys(prices)

    return 0 if pricesDays.length == 0
    block_size = _.inject pricesDays, (largestBlock, blockDays) ->
      largestBlock = blockDays if days >= blockDays
      largestBlock
    @pricing = prices[block_size]
    price = @pricing.price

    if @listing.hasFavourablePricingRate() || days < block_size
      Math.round((days/block_size) * price)
    else
      priced_days = Math.floor(days/block_size)
      left_days = days - priced_days*(block_size)
      calculated_price = Math.round(priced_days * price)
      if left_days == 0
        calculated_price
      else
        calculated_price + @priceForDays(left_days)

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

  contiguousOvernightBlocks: ->
    dates = _.inject(@listing.bookedDates(), (groups, datetime) ->
      previous_group = groups[-1..][0]
      if previous_group && dateUtil.toId(dateUtil.next(previous_group[-1..][0])) == dateUtil.toId(datetime)
        previous_group.push datetime
      else
        groups.push [datetime]
      groups
    , [])

  isContiguous: (from, to) ->
    return false if to.getTime() < from.getTime()

    while from.getTime() < to.getTime()
      from = dateUtil.next(from)
      break if @listing.canBookDate(from)

    return dateUtil.toId(from) == dateUtil.toId(to)
