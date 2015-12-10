AdditionalChargesCalculator = require('../additional_charges');

module.exports = class HourlyPriceCalculator
  constructor: (@listing) ->
    @additionalCharges = new AdditionalChargesCalculator($("#additional-charges-#{@listing.id}"), @listing.data.subunit_to_unit_rate)

  getPrice: ->
    bookedHours = (@listing.minutesBooked()/60)*@listing.bookedDates().length
    total = @listing.hourlyPrice*bookedHours*@listing.getQuantity()
    total += @additionalCharges.getCharges()




