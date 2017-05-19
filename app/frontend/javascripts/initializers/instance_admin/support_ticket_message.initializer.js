var el = $('.message-form');
if (el.length > 0) {
  require.ensure('../../sections/support/ticket_message_controller', function(require) {
    var SupportTicketMessageController = require(
      '../../sections/support/ticket_message_controller'
    );
    return new SupportTicketMessageController(el);
  });
}
