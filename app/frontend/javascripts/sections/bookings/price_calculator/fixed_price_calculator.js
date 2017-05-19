var AdditionalChargesCalculator, FixedPriceCalculator;

AdditionalChargesCalculator = require('../additional_charges');

FixedPriceCalculator = function() {
  function FixedPriceCalculator(listing) {
    this.listing = listing;
    this.additionalCharges = new AdditionalChargesCalculator(
      $('#additional-charges-' + this.listing.id),
      this.listing.data.subunit_to_unit_rate
    );
  }

  FixedPriceCalculator.prototype.getPrice = function() {
    var total;
    total = this.listing.fixedPrice * this.listing.getQuantity();
    return total += this.additionalCharges.getCharges(total);
  };

  FixedPriceCalculator.prototype.getPriceForBookItOut = function() {
    var total;
    total = _.inject(
      this.listing.bookedDates(),
      function(_this) {
        return function(sum) {
          return sum + _this.listing.getQuantity() * _this.listing.fixedPrice;
        };
      }(this),
      0
    );
    total *= (100 - this.listing.data.book_it_out_discount) / 100;
    return total += this.additionalCharges.getCharges(total);
  };

  return FixedPriceCalculator;
}();

module.exports = FixedPriceCalculator;
