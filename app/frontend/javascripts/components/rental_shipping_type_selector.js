var JavascriptModule,
  RentalShippingTypeSelector,
  ShippoDimensionable,
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

JavascriptModule = require('../lib/javascript_module');

ShippoDimensionable = require('../lib/shippo_dimensionable');

RentalShippingTypeSelector = function(superClass) {
  extend(RentalShippingTypeSelector, superClass);

  RentalShippingTypeSelector.include(ShippoDimensionable);

  function RentalShippingTypeSelector(select, dimensionsTemplatesContainer, units) {
    this.units = units;
    this.select = select;
    this.dimensionsTemplatesContainer = dimensionsTemplatesContainer;
    this.updateDimensionsFieldsFromTemplates();
    select.on(
      'change',
      function(_this) {
        return function() {
          return _this.toggleDimensionsContainer();
        };
      }(this)
    );
    setTimeout(
      function(_this) {
        return function() {
          _this.toggleDimensionsContainer();
        };
      }(this),
      200
    );
  }

  RentalShippingTypeSelector.prototype.toggleDimensionsContainer = function() {
    if (this.select.val() === 'delivery' || this.select.val() === 'both') {
      this.dimensionsTemplatesContainer.show();
      return $('input[data-remove-object]').val('');
    } else {
      this.dimensionsTemplatesContainer.hide();
      return $('input[data-remove-object]').val('1');
    }
  };

  return RentalShippingTypeSelector;
}(JavascriptModule);

module.exports = RentalShippingTypeSelector;
