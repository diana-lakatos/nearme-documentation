var AdditionalChargesCalculator, BookingsPriceCalculator, dateUtil;

AdditionalChargesCalculator = require('./additional_charges');

dateUtil = require('../../lib/utils/date');

/*
 * Object encapsulating our pricing calculation logic.
 *
 * NB: Note that there is a corresponding Ruby calculating class
 *     to calculate the price server-side. If the logic changes,
 *     be sure to update that as well.
 */
BookingsPriceCalculator = function() {
  function BookingsPriceCalculator(listing) {
    this.listing = listing;
    this.additionalCharges = new AdditionalChargesCalculator(
      $('#additional-charges-' + this.listing.id),
      this.listing.data.subunit_to_unit_rate
    );
  }

  BookingsPriceCalculator.prototype.getPrice = function() {
    var contiguousBlocks, total;
    contiguousBlocks = this.contiguousBlocks();
    total = _.inject(
      contiguousBlocks,
      function(_this) {
        return function(sum, block) {
          var block_length;
          block_length = block.length;
          if (_this.listing.isOvernightBooking() && block_length > 1) {
            block_length = block_length - 1;
          }
          return sum + _this.priceForDays(block_length) * _this.listing.getQuantity();
        };
      }(this),
      0
    );
    total += this.additionalCharges.getCharges(total);
    if (this.pricing) {
      this.listing.currentPricingId = this.pricing.id;
    }
    return total;
  };

  BookingsPriceCalculator.prototype.priceForDays = function(days) {
    var block_size, calculated_price, left_days, price, priced_days, prices, pricesDays;
    prices = this.listing.isOvernightBooking()
      ? this.listing.pricesByNights
      : this.listing.pricesByDays;
    pricesDays = _.keys(prices);
    if (pricesDays.length === 0) {
      return 0;
    }
    block_size = _.inject(pricesDays, function(largestBlock, blockDays) {
      if (days >= blockDays) {
        largestBlock = blockDays;
      }
      return largestBlock;
    });
    this.pricing = prices[block_size];
    price = this.pricing.price;
    if (this.listing.hasFavourablePricingRate() || days < block_size) {
      return Math.round(days / block_size * price);
    } else {
      priced_days = Math.floor(days / block_size);
      left_days = days - priced_days * block_size;
      calculated_price = Math.round(priced_days * price);
      if (left_days === 0) {
        return calculated_price;
      } else {
        return calculated_price + this.priceForDays(left_days);
      }
    }
  };

  BookingsPriceCalculator.prototype.contiguousBlocks = function() {
    var blocks, current_block, date, dates, i, len, previous_date;
    dates = _.sortBy(this.listing.bookedDates(), function(date) {
      return date.getTime();
    });
    blocks = [];
    current_block = null;
    previous_date = null;
    for (i = 0, len = dates.length; i < len; i++) {
      date = dates[i];

      /*
       * Every time we break a contiguous
       */
      if (!previous_date || !this.isContiguous(previous_date, date)) {
        current_block = [];
        blocks.push(current_block);
      }
      current_block.push(date);
      previous_date = date;
    }
    return blocks;
  };

  BookingsPriceCalculator.prototype.contiguousOvernightBlocks = function() {
    return _.inject(
      this.listing.bookedDates(),
      function(groups, datetime) {
        var previous_group;
        previous_group = groups.slice(-1)[0];
        if (
          previous_group &&
            dateUtil.toId(dateUtil.next(previous_group.slice(-1)[0])) === dateUtil.toId(datetime)
        ) {
          previous_group.push(datetime);
        } else {
          groups.push([ datetime ]);
        }
        return groups;
      },
      []
    );
  };

  BookingsPriceCalculator.prototype.isContiguous = function(from, to) {
    if (to.getTime() < from.getTime()) {
      return false;
    }
    while (from.getTime() < to.getTime()) {
      from = dateUtil.next(from);
      if (this.listing.canBookDate(from)) {
        break;
      }
    }
    return dateUtil.toId(from) === dateUtil.toId(to);
  };

  return BookingsPriceCalculator;
}();

module.exports = BookingsPriceCalculator;
