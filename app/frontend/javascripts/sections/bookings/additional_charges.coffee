module.exports = class AdditionalChargesCalculator
  constructor: (@container, @subunit_to_unit_rate = 100) ->

  getMandatoryCharges: ->
    @container.find('[data-mandatory-charge]')

  getActiveOptionalCharges: ->
    @container.find('[data-optional-charge]')

  getCharges: ->
    total = 0
    charges = []
    charges.push @getMandatoryCharges().get()
    charges.push @getActiveOptionalCharges().get()
    charges = _.flatten(charges)

    for charge in charges
      $charge = $(charge)
      if ($oc = $charge.find('[data-optional-charge-select]')).length > 0
        if $oc.is(':checked')
          total += parseFloat($charge.data().optionalCharge)
      else
        total += parseFloat($charge.data().mandatoryCharge)
    total * @subunit_to_unit_rate
