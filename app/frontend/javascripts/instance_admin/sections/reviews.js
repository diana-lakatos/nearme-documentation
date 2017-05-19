var InstanceAdminReviewsController,
  JavascriptModule,
  SearchableAdminResource,
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

require('../../../vendor/jquery-ui-datepicker');

InstanceAdminReviewsController = function(superClass) {
  extend(InstanceAdminReviewsController, superClass);

  InstanceAdminReviewsController.include(SearchableAdminResource);

  function InstanceAdminReviewsController(container) {
    this.container = container;
    this.commonBindEvents();
    this.bindEvents();
  }

  InstanceAdminReviewsController.prototype.bindEvents = function() {
    this.container.find('#to, #from').datepicker();
    this.container.on('click', '#to, #from', function(e) {
      return e.stopPropagation();
    });
    this.container.on(
      'click',
      '.more-filters',
      function(_this) {
        return function() {
          _this.container.find('.filters-expanded').slideToggle();
          _this.container.find('.more-filters').toggleClass('active');
          return _this.container
            .find('.more-filters .fa')
            .toggleClass('fa-angle-right fa-angle-down');
        };
      }(this)
    );
    return this.container.find('.filters-expanded').on(
      'click',
      '.close-link',
      function(_this) {
        return function() {
          _this.container.find('.filters-expanded').slideUp();
          _this.container.find('.more-filters').removeClass('active');
          return _this.container
            .find('.more-filters .fa')
            .toggleClass('fa-angle-down fa-angle-right');
        };
      }(this)
    );
  };

  return InstanceAdminReviewsController;
}(JavascriptModule);

module.exports = InstanceAdminReviewsController;
