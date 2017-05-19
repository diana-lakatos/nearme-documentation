var link = $('#support-tickets-link');
if (link.length > 0) {
  require.ensure('../../sections/support_tickets', function(require) {
    var SupportTickets = require('../../sections/support_tickets');
    return new SupportTickets(link);
  });
}

var el = $('#support-ticket-message-controller');
if (el.length > 0) {
  require.ensure('../../sections/support/ticket_message_controller', function(require) {
    var SupportTicketMessageController = require(
      '../../sections/support/ticket_message_controller'
    );
    return new SupportTicketMessageController(el);
  });
}
