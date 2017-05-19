var InstanceAdminBuySellController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

InstanceAdminBuySellController = function() {
  function InstanceAdminBuySellController(container) {
    this.container = container;
    this.bindEvents = bind(this.bindEvents, this);
    this.bindEvents();
  }

  InstanceAdminBuySellController.prototype.bindEvents = function() {
    return this.container.find('input.zone_kind').on(
      'change',
      function(_this) {
        return function(e) {
          _this.container.find('.zone-members-container').addClass('hide');
          return _this.container
            .find('#' + $(e.currentTarget).attr('id') + '_container')
            .removeClass('hide');
        };
      }(this)
    );
  };

  return InstanceAdminBuySellController;
}();

module.exports = InstanceAdminBuySellController;
