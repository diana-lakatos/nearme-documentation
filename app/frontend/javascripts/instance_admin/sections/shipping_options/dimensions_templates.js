var DimensionsTemplates,
  JavascriptModule,
  ShippoDimensionableAdmin,
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

JavascriptModule = require('../../../lib/javascript_module');

ShippoDimensionableAdmin = require('../../../lib/shippo_dimensionable_admin');

DimensionsTemplates = function(superClass) {
  extend(DimensionsTemplates, superClass);

  DimensionsTemplates.include(ShippoDimensionableAdmin);

  function DimensionsTemplates(el) {
    this.units = $(el).data('units');
    this.updateUnitsOfMeasure();
  }

  return DimensionsTemplates;
}(JavascriptModule);

module.exports = DimensionsTemplates;
