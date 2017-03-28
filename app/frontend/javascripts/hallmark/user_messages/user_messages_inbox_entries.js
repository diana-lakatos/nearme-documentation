// @flow
const WRAPPER_SELECTOR = '[data-user-messages-inbox-conversation]';
import UserMessagesInboxEntry from './user_messages_inbox_entry';
import { closest } from '../../toolkit/dom';

class UserMessagesInboxEntries {
  container: HTMLElement;
  entries: Array<UserMessagesInboxEntry>;
  wrapper: HTMLElement;

  constructor(container: HTMLElement) {
    this.container = container;
    let wrapper = closest(this.container, WRAPPER_SELECTOR);
    if (!(wrapper instanceof HTMLElement)) {
      throw new Error('Unable to locate wrapper element for inbox entries');
    }
    this.wrapper = wrapper;
    this.entries = [];
    this.parse();

    this.scrollToBottom();
  }

  parse() {
    let els = this.container.querySelectorAll('p');

    Array.prototype.forEach.call(els, (el: HTMLElement) => {
      let entry = UserMessagesInboxEntry.parse(el);
      this.entries.push(entry);
    });
  }

  add(entry: UserMessagesInboxEntry) {
    this.entries.push(entry);
    this.container.appendChild(entry.getElement());

    this.scrollToBottom();
  }

  scrollToBottom() {
    this.wrapper.scrollTop = this.wrapper.scrollHeight;
  }
}

module.exports = UserMessagesInboxEntries;
