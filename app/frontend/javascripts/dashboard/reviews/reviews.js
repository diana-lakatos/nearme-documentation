var Review,
  Reviews,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

Review = require('./review');

Reviews = function() {
  function Reviews(container) {
    this.updatePeriod = bind(this.updatePeriod, this);
    this.container = $(container);
    this.reviews = this.container.find('[data-review-form]');
    this.periodSelector = this.container.find('select[data-period-selection]');
    this.bindEvents();
    this.initialize();
  }

  Reviews.prototype.bindEvents = function() {
    return this.periodSelector.on('change', this.updatePeriod);
  };

  Reviews.prototype.updatePeriod = function() {
    var periodSearchString, searchString;
    periodSearchString = 'period=' + this.periodSelector.val();
    searchString = window.location.search;
    if (searchString) {
      if (searchString.match(/period=\w+/)) {
        return window.location.search = searchString.replace(/period=\w+/, periodSearchString);
      } else {
        return window.location.search += '&' + periodSearchString;
      }
    } else {
      return window.location.search = periodSearchString;
    }
  };

  Reviews.prototype.initialize = function() {
    return this.reviews.each(function() {
      return new Review(this);
    });
  };

  return Reviews;
}();

module.exports = Reviews;
