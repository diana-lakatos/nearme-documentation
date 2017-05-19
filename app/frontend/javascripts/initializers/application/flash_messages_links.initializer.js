var alert = document.querySelector('.alert');

if (alert !== null) {
  require.ensure([ '../../shared/flash_messages_links' ], function(require) {
    var FlashMessagesLinks = require('../../shared/flash_messages_links');

    new FlashMessagesLinks(alert);
  });
}
