var AdditionalChargesCalculator, HourlyPriceCalculator;

AdditionalChargesCalculator = require('../additional_charges');

HourlyPriceCalculator = function() {
  function HourlyPriceCalculator(listing) {
    this.listing = listing;
    this.additionalCharges = new AdditionalChargesCalculator(
      $('#additional-charges-' + this.listing.id),
      this.listing.data.subunit_to_unit_rate
    );
  }

  HourlyPriceCalculator.prototype.getPrice = function() {
    var total;
    total = this.priceForHours(this.listing.minutesBooked() / 60) * this.listing.getQuantity();
    total += this.additionalCharges.getCharges(total);
    if (this.pricing) {
      this.listing.currentPricingId = this.pricing.id;
    }
    return total;
  };

  HourlyPriceCalculator.prototype.priceForHours = function(hours) {
    var block_size, calculated_price, left_hours, price, priced_hours, prices, pricesHours;
    prices = this.listing.pricesByHours;
    pricesHours = _.keys(prices);
    if (pricesHours.length === 0) {
      return 0;
    }
    block_size = _.inject(pricesHours, function(largestBlock, blockDays) {
      if (hours >= blockDays) {
        largestBlock = blockDays;
      }
      return largestBlock;
    });
    this.pricing = prices[block_size];
    price = this.pricing.price;
    if (this.listing.hasFavourablePricingRate() || hours < block_size) {
      return Math.round(hours / block_size * price);
    } else {
      priced_hours = Math.floor(hours / block_size);
      left_hours = hours - priced_hours * block_size;
      calculated_price = Math.round(priced_hours * price);
      if (left_hours === 0) {
        return calculated_price;
      } else {
        return calculated_price + this.priceForHours(left_hours);
      }
    }
  };

  return HourlyPriceCalculator;
}();

module.exports = HourlyPriceCalculator;
