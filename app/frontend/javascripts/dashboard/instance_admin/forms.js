var InstanceAdminForms;

require('chosen/chosen.jquery');

InstanceAdminForms = function() {
  function InstanceAdminForms() {
    this.datepickers = require('../forms/datepickers');
    this.timepickers = require('../forms/timepickers');
    this.root = $('html');
    this.bindEvents();
    this.datepickers();
    this.timepickers();
    this.selects();
  }

  InstanceAdminForms.prototype.bindEvents = function() {
    this.root.on(
      'datepickers.init.forms',
      function(_this) {
        return function(event, context) {
          if (context == null) {
            context = 'body';
          }
          return _this.datepickers(context);
        };
      }(this)
    );
    this.root.on(
      'timepickers.init.forms',
      function(_this) {
        return function(event, context) {
          if (context == null) {
            context = 'body';
          }
          return _this.timepickers(context);
        };
      }(this)
    );
    return this.root.on(
      'selects.init.forms',
      function(_this) {
        return function(event, context) {
          if (context == null) {
            context = 'body';
          }
          return _this.selects(context);
        };
      }(this)
    );
  };

  InstanceAdminForms.prototype.selects = function(context) {
    if (context == null) {
      context = 'body';
    }
    return $(context).find('select.select').chosen({ width: '100%' });
  };

  return InstanceAdminForms;
}();

module.exports = InstanceAdminForms;
