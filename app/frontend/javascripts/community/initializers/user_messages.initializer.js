// @flow
let inbox = document.querySelector('[data-user-messages-inbox]');

if (inbox instanceof HTMLElement) {
  require.ensure('../user_messages/user_messages_inbox.js', require => {
    let UserMessagesInbox = require('../user_messages/user_messages_inbox.js');
    new UserMessagesInbox(inbox);
  });
}
