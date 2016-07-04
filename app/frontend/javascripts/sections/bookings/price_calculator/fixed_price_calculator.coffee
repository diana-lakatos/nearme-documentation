AdditionalChargesCalculator = require('../additional_charges')

module.exports = class FixedPriceCalculator
  constructor: (@listing) ->
    @additionalCharges = new AdditionalChargesCalculator($("#additional-charges-#{@listing.id}"), @listing.data.subunit_to_unit_rate)

  getPrice: ->
    total = @listing.fixedPrice*@listing.getQuantity()
    total += @additionalCharges.getCharges(total)

  getPriceForBookItOut: ->
    total = _.inject(@listing.bookedDates(), (sum, date) =>
      sum + (@listing.getQuantity() * @listing.fixedPrice)
    , 0)
    total *= (100 - @listing.data.book_it_out_discount) / 100
    total += @additionalCharges.getCharges(total)
