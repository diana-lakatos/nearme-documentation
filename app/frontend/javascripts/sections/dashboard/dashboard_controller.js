var DashboardController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

DashboardController = function() {
  function DashboardController(container) {
    this.container = container;
    this.setMaxWidth = bind(this.setMaxWidth, this);
    this.bindEvents = bind(this.bindEvents, this);
    this.bindEvents();
    this.setMaxWidth();
  }

  DashboardController.prototype.bindEvents = function() {
    return $(window).resize(
      function(_this) {
        return function() {
          return _this.setMaxWidth();
        };
      }(this)
    );
  };

  DashboardController.prototype.setMaxWidth = function() {
    this.location = this.container.find('li.location').eq(0);
    $(
      'li.location .name'
    ).css('maxWidth', this.location.width() - $(this.location).find('.links').width() - 10 + 'px');
    return this.container.find('li.listing').each(function(index, element) {
      return $(element)
        .find('.name')
        .css('maxWidth', $(element).width() - $(element).find('a').width() - 10 + 'px');
    });
  };

  return DashboardController;
}();

module.exports = DashboardController;
