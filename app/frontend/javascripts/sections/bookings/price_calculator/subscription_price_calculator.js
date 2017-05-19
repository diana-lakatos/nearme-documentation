var AdditionalChargesCalculator, SubscriptionPriceCalculator;

AdditionalChargesCalculator = require('../additional_charges');

SubscriptionPriceCalculator = function() {
  function SubscriptionPriceCalculator(listing) {
    this.listing = listing;
    this.additionalCharges = new AdditionalChargesCalculator(
      $('#additional-charges-' + this.listing.id),
      this.listing.data.subunit_to_unit_rate
    );
  }

  SubscriptionPriceCalculator.prototype.getPrice = function() {
    var total;
    total = this.listing.data.pricings[this.listing.currentPricingId].price *
      this.listing.getQuantity();
    total += this.additionalCharges.getCharges(total);
    return total;
  };

  return SubscriptionPriceCalculator;
}();

module.exports = SubscriptionPriceCalculator;
