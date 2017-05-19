var InstanceAdminProductsController,
  JavascriptModule,
  SearchableAdminResource,
  SearchableAdminService,
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

SearchableAdminResource = require('../searchable_admin_resource');

SearchableAdminService = require('../searchable_admin_service');

InstanceAdminProductsController = function(superClass) {
  extend(InstanceAdminProductsController, superClass);

  InstanceAdminProductsController.include(SearchableAdminResource);

  InstanceAdminProductsController.include(SearchableAdminService);

  function InstanceAdminProductsController(container) {
    this.container = container;
    this.commonBindEvents();
    this.serviceBindEvents();
  }

  return InstanceAdminProductsController;
}(JavascriptModule);

module.exports = InstanceAdminProductsController;
