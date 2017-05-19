var els = $('.rfq-form-a');
if (els.length > 0) {
  require.ensure('../../dashboard/controllers/ticket_message_controller', function(require) {
    var TicketMessageController = require('../../dashboard/controllers/ticket_message_controller');
    els.each(function() {
      return new TicketMessageController(this);
    });
  });
}
