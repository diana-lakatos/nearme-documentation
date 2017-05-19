var OrdersController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

OrdersController = function() {
  function OrdersController(container) {
    this.container = container;
    this.bindEvents = bind(this.bindEvents, this);
    this.detailsLinks = this.container.find('[data-order-details]');
    this.bindEvents();
  }

  OrdersController.prototype.bindEvents = function() {
    return this.detailsLinks.click(function(e) {
      var detailsContainer;
      e.preventDefault();
      detailsContainer = $(e.target).parents('.order-row').next();
      if (detailsContainer.hasClass('hidden')) {
        detailsContainer.hide().removeClass('hidden').show('slow');
        if ($(e.target).text() === 'Details') {
          return $(e.target).text('Hide');
        }
      } else {
        detailsContainer.hide('slow', function() {
          return $(this).addClass('hidden');
        });
        if ($(e.target).text() === 'Hide') {
          return $(e.target).text('Details');
        }
      }
    });
  };

  return OrdersController;
}();

module.exports = OrdersController;
