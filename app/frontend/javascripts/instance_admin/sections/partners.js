var InstanceAdminPartnersController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

InstanceAdminPartnersController = function() {
  function InstanceAdminPartnersController(form) {
    this.form = form;
    this.bindEvents = bind(this.bindEvents, this);
    this.bindEvents();
  }

  InstanceAdminPartnersController.prototype.bindEvents = function() {
    return $('input[data-submit-add-theme]').on(
      'click',
      function(_this) {
        return function(event) {
          event.preventDefault();
          $('<input>').attr({ type: 'hidden', name: 'add_theme' }).val('1').appendTo(_this.form);
          return _this.form.submit();
        };
      }(this)
    );
  };

  return InstanceAdminPartnersController;
}();

module.exports = InstanceAdminPartnersController;
