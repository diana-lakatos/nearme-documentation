var els = $('[data-order-items]');
if (els.length > 0) {
  require.ensure('../../dashboard/controllers/order_items_controller', function(require) {
    var OrderItemsController = require('../../dashboard/controllers/order_items_controller');
    els.each(function() {
      return new OrderItemsController(this);
    });
  });
}

var orderExpenses = $('[data-expenses-overview]');
if (orderExpenses.length > 0) {
  require.ensure('../../dashboard/modules/order_items_index', function(require) {
    var OrderItemsIndex = require('../../dashboard/modules/order_items_index');
    orderExpenses.each(function() {
      return new OrderItemsIndex(this);
    });
  });
}
