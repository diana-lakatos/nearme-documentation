var DashboardAnalyticsController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

DashboardAnalyticsController = function() {
  function DashboardAnalyticsController(container) {
    this.container = container;
    this.bindEvents = bind(this.bindEvents, this);
    this.analyticsModeSelect = this.container.find('select.analytics-mode');
    this.start_value = this.analyticsModeSelect.val();
    this.bindEvents();
  }

  DashboardAnalyticsController.prototype.bindEvents = function() {
    return this.analyticsModeSelect.on(
      'change',
      function(_this) {
        return function() {
          /*
         * without this there is infinite redirction on page load
         */
          if (_this.start_value === _this.analyticsModeSelect.val()) {
            return _this.start_value = null;
          } else {
            return location.href = location.pathname + '?analytics_mode=' +
              _this.analyticsModeSelect.val();
          }
        };
      }(this)
    );
  };

  return DashboardAnalyticsController;
}();

module.exports = DashboardAnalyticsController;
