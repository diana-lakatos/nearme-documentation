var JavascriptModule,
  ShippoDimensionableAdmin,
  UserDimensionsTemplates,
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

JavascriptModule = require('../../lib/javascript_module');

ShippoDimensionableAdmin = require('../../lib/shippo_dimensionable_admin');

UserDimensionsTemplates = function(superClass) {
  extend(UserDimensionsTemplates, superClass);

  UserDimensionsTemplates.include(ShippoDimensionableAdmin);

  function UserDimensionsTemplates(units) {
    this.units = units;
    this.updateUnitsOfMeasure();
  }

  return UserDimensionsTemplates;
}(JavascriptModule);

module.exports = UserDimensionsTemplates;
