var HomeController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

HomeController = function() {
  function HomeController(container) {
    this.bindEvents = bind(this.bindEvents, this);
    this.container = $(container);
    this.callToAction = this.container.find('a[data-call-to-action]');
    this.howItWorks = $('section.how-it-works');
    this.homepageContentTopOffset = 90;
    if (!(this.callToAction.length !== 0 && this.howItWorks.length !== 0)) {
      return;
    }
    this.bindEvents();
  }

  HomeController.prototype.bindEvents = function() {
    return this.callToAction.on(
      'click',
      function(_this) {
        return function() {
          var content_top;
          content_top = _this.howItWorks.offset().top - _this.homepageContentTopOffset;
          $('html, body').animate({ scrollTop: content_top }, 900);
          return false;
        };
      }(this)
    );
  };

  return HomeController;
}();

module.exports = HomeController;
