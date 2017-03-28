// @flow
const FORM_SELECTOR = '[data-user-messages-inbox-form]';
const ENTRIES_SELECTOR = '[data-user-messages-inbox-entries]';
import UserMessagesInboxContactList from './user_messages_inbox_contact_list';
import UserMessagesInboxForm from './user_messages_inbox_form';
import UserMessagesInboxEntries from './user_messages_inbox_entries';
import UserMessagesInboxEntry from './user_messages_inbox_entry';

class UserMessagesInbox {
  container: HTMLElement;
  contactList: UserMessagesInboxContactList;
  form: UserMessagesInboxForm;
  entries: UserMessagesInboxEntries;

  constructor(container: HTMLElement) {
    this.container = container;
    this.contactList = new UserMessagesInboxContactList(this.container);

    let form = this.container.querySelector(FORM_SELECTOR);
    if (form instanceof HTMLFormElement) {
      this.form = new UserMessagesInboxForm(form);
    }

    let entries = this.container.querySelector(ENTRIES_SELECTOR);
    if (entries instanceof HTMLElement) {
      this.entries = new UserMessagesInboxEntries(entries);
    }

    if (this.entries && this.form) {
      this.bindEvents();
    }
  }

  bindEvents() {
    this.form.on('newentry', (entry: UserMessagesInboxEntry) => {
      this.entries.add(entry);
    });
  }
}

module.exports = UserMessagesInbox;
