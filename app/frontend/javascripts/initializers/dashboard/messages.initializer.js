$(document).on('init:user_messages.nearme', function() {
  require.ensure('../../dashboard/controllers/messages_controller', function(require) {
    var MessagesController = require('../../dashboard/controllers/messages_controller');
    return new MessagesController($('[data-messages-form]'));
  });
});

var els = $('[data-messages-form]');
if (els.length > 0) {
  require.ensure('../../dashboard/controllers/messages_controller', function(require) {
    var MessagesController = require('../../dashboard/controllers/messages_controller');
    els.each(function() {
      return new MessagesController(this);
    });
  });
}
