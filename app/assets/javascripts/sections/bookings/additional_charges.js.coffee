class @Bookings.AdditionalChargesCalculator
  constructor: ->
    @container = $('#additional_charges')

  getMandatoryCharges: ->
    mandatoryCharges = @container.find('.mandatory-charge span.charge-amount')

  getActiveOptionalCharges: ->
    optionalCharges = @container.find('.optional-charge span.charge-amount')

  getCharges: ->
    total = 0
    charges = []
    charges.push @getMandatoryCharges().get()
    charges.push @getActiveOptionalCharges().get()
    charges = _.flatten(charges)

    for charge in charges
      $charge = $(charge)
      if ($oc = $charge.closest('.optional-charge')).length > 0
        if $oc.find('input[type=checkbox]:checked').length > 0
          total += parseFloat($charge.text())
      else
        total += parseFloat($charge.text())
    total * 100
