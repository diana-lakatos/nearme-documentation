var FixedPriceCalculator,
  PerUnitPriceCalculator,
  extend = function(child, parent) {
    for (var key in parent) {
      if (hasProp.call(parent, key))
        child[key] = parent[key];
    }
    function ctor() {
      this.constructor = child;
    }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor();
    child.__super__ = parent.prototype;
    return child;
  },
  hasProp = {}.hasOwnProperty;

FixedPriceCalculator = require('./fixed_price_calculator');

PerUnitPriceCalculator = function(superClass) {
  extend(PerUnitPriceCalculator, superClass);

  function PerUnitPriceCalculator() {
    return PerUnitPriceCalculator.__super__.constructor.apply(this, arguments);
  }

  return PerUnitPriceCalculator;
}(FixedPriceCalculator);

module.exports = PerUnitPriceCalculator;
