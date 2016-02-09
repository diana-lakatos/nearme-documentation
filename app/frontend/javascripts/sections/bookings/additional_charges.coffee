module.exports = class AdditionalChargesCalculator
  constructor: (@container, @subunit_to_unit_rate = 100) ->

  getMandatoryCharges: ->
    @container.find('[data-mandatory-charge]')

  getActiveOptionalCharges: ->
    @container.find('[data-optional-charge]')

  getCharges: (reservation_price) ->
    reservation_price ?= 0
    total = 0
    charges = []
    charges.push @getMandatoryCharges().get()
    charges.push @getActiveOptionalCharges().get()
    charges = _.flatten(charges)

    for charge in charges
      $charge = $(charge)
      if ($oc = $charge.find('[data-optional-charge-select]')).length > 0
        if parseFloat($charge.data().chargePercent) > 0
          charge_price = parseFloat(($charge.data().chargePercent/100 * reservation_price) / @subunit_to_unit_rate)
          $charge.data().optionalCharge = charge_price
          $charge.find(".pull-right").text($charge.data().currency + ' ' + charge_price.toFixed(2) )
        if $oc.is(':checked')
          total += parseFloat($charge.data().optionalCharge)
      else
        if parseFloat($charge.data().chargePercent) > 0
          charge_price = parseFloat(($charge.data().chargePercent/100 * reservation_price) / @subunit_to_unit_rate)
          total += charge_price
          $charge.find(".pull-right").text($charge.data().currency + ' ' + charge_price.toFixed(2) )
        else
          total += parseFloat($charge.data().mandatoryCharge)
    total * @subunit_to_unit_rate
