AdditionalChargesCalculator = require('../additional_charges')

module.exports = class HourlyPriceCalculator
  constructor: (@listing) ->
    @additionalCharges = new AdditionalChargesCalculator($("#additional-charges-#{@listing.id}"), @listing.data.subunit_to_unit_rate)

  getPrice: ->
    total = @priceForHours((@listing.minutesBooked()/60))*@listing.getQuantity()
    total += @additionalCharges.getCharges(total)
    if @pricing
      @listing.currentPricingId = @pricing.id
    total


  priceForHours: (hours) ->
    prices = @listing.pricesByHours
    pricesHours = _.keys(prices)

    return 0 if pricesHours.length == 0
    block_size = _.inject pricesHours, (largestBlock, blockDays) ->
      largestBlock = blockDays if hours >= blockDays
      largestBlock
    @pricing = prices[block_size]
    price = @pricing.price

    if @listing.hasFavourablePricingRate() || hours < block_size
      Math.round((hours/block_size) * price)
    else
      priced_hours = Math.floor(hours/block_size)
      left_hours = hours - priced_hours*(block_size)
      calculated_price = Math.round(priced_hours * price)
      if left_hours == 0
        calculated_price
      else
        calculated_price + @priceForHours(left_hours)
