var SupportTickets;

require('jquery-inview/jquery.inview');

SupportTickets = function() {
  function SupportTickets(container) {
    this.container = container;
    $(this.container).on('inview', function(e, visible) {
      if (!visible) {
        return;
      }
      return $.getScript($(this).attr('href'));
    });
  }

  return SupportTickets;
}();

module.exports = SupportTickets;
