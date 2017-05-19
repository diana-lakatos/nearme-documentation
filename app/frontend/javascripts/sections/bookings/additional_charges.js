var AdditionalChargesCalculator;

AdditionalChargesCalculator = function() {
  function AdditionalChargesCalculator(container, subunit_to_unit_rate) {
    this.container = container;
    this.subunit_to_unit_rate = subunit_to_unit_rate != null ? subunit_to_unit_rate : 100;
  }

  AdditionalChargesCalculator.prototype.getMandatoryCharges = function() {
    return this.container.find('[data-mandatory-charge]');
  };

  AdditionalChargesCalculator.prototype.getActiveOptionalCharges = function() {
    return this.container.find('[data-optional-charge]');
  };

  AdditionalChargesCalculator.prototype.getCharges = function(reservation_price) {
    var $charge, $oc, charge, charge_price, charges, i, len, total;
    if (reservation_price == null) {
      reservation_price = 0;
    }
    total = 0;
    charges = [];
    charges.push(this.getMandatoryCharges().get());
    charges.push(this.getActiveOptionalCharges().get());
    charges = _.flatten(charges);
    for (i = 0, len = charges.length; i < len; i++) {
      charge = charges[i];
      $charge = $(charge);
      $oc = $charge.find('[data-optional-charge-select]');
      if ($oc.length > 0) {
        if (parseFloat($charge.data().chargePercent) > 0) {
          charge_price = parseFloat(
            $charge.data().chargePercent / 100 * reservation_price / this.subunit_to_unit_rate
          );
          $charge.data().optionalCharge = charge_price;
          $charge.find('.pull-right').text($charge.data().currency + ' ' + charge_price.toFixed(2));
        }
        if ($oc.is(':checked')) {
          total += parseFloat($charge.data().optionalCharge);
        }
      } else {
        if (parseFloat($charge.data().chargePercent) > 0) {
          charge_price = parseFloat(
            $charge.data().chargePercent / 100 * reservation_price / this.subunit_to_unit_rate
          );
          total += charge_price;
          $charge.find('.pull-right').text($charge.data().currency + ' ' + charge_price.toFixed(2));
        } else {
          total += parseFloat($charge.data().mandatoryCharge);
        }
      }
    }
    return total * this.subunit_to_unit_rate;
  };

  return AdditionalChargesCalculator;
}();

module.exports = AdditionalChargesCalculator;
