AdditionalChargesCalculator = require('../additional_charges')

module.exports = class SubscriptionPriceCalculator
  constructor: (@listing) ->
    @additionalCharges = new AdditionalChargesCalculator($("#additional-charges-#{@listing.id}"), @listing.data.subunit_to_unit_rate)

  getPrice: ->
    total = @listing.data.pricings[@listing.currentPricingId].price * @listing.getQuantity()
    total += @additionalCharges.getCharges(total)
    total
