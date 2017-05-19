var ordersList = $('.orders-a');
if (ordersList.length > 0) {
  $(document).on('init:orders.nearme', function() {
    require.ensure('../../dashboard/controllers/orders_controller', function(require) {
      var OrdersController = require('../../dashboard/controllers/orders_controller');
      new OrdersController(ordersList);
    });
  });
}

$(document).on('init:disableorderform.nearme', function(event, form) {
  $(form).find('input, textarea, button, select').attr('disabled', 'disabled');
});
