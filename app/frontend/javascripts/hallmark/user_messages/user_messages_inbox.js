// @flow
const FORM_SELECTOR = '[data-user-messages-inbox-form]';
const ENTRIES_SELECTOR = '[data-user-messages-inbox-entries]';
const CONTACT_LIST_SELECTOR = '[data-user-messages-contact-list]';
const USER_SEARCH_SELECTOR = '[data-user-messages-user-search]';

import UserMessagesInboxContactList from './user_messages_inbox_contact_list';
import UserMessagesInboxForm from './user_messages_inbox_form';
import UserMessagesInboxEntries from './user_messages_inbox_entries';
import UserMessagesInboxEntry from './user_messages_inbox_entry';
import UserMessagesInboxUserSearchForm from './user_messages_inbox_user_search_form';

const Modal = require('../modal');

class UserMessagesInbox {
  container: HTMLElement;
  contactList: UserMessagesInboxContactList;
  form: UserMessagesInboxForm;
  entries: UserMessagesInboxEntries;
  userSearchForm: UserMessagesInboxUserSearchForm;

  constructor(container: HTMLElement) {
    this.container = container;

    let contactList = this.container.querySelector(CONTACT_LIST_SELECTOR);
    if (contactList instanceof HTMLElement) {
      this.contactList = new UserMessagesInboxContactList(this.container);
    }

    let form = this.container.querySelector(FORM_SELECTOR);
    if (form instanceof HTMLFormElement) {
      this.form = new UserMessagesInboxForm(form);
    }

    let entries = this.container.querySelector(ENTRIES_SELECTOR);
    if (entries instanceof HTMLElement) {
      this.entries = new UserMessagesInboxEntries(entries);
    }

    let userSearchForm = this.container.querySelector(USER_SEARCH_SELECTOR);
    if (userSearchForm instanceof HTMLFormElement) {
      this.userSearchForm = new UserMessagesInboxUserSearchForm(userSearchForm);
    }

    if (this.entries && this.form) {
      this.bindEvents();
    }
  }

  bindEvents() {
    this.form.on('newentry', (entry: UserMessagesInboxEntry) => {
      this.entries.add(entry);
    });

    this.userSearchForm.on(
      'user:selected',
      (data: { user: { id: number, name: string, profileUrl: string, avatarUrl: string } }) => {
        Modal.load({
          url: `/users/${data.user.id}/user_messages/new`
        });
      }
    );
  }
}

module.exports = UserMessagesInbox;
