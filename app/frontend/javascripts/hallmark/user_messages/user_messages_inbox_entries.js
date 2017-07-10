// @flow
const WRAPPER_SELECTOR = '[data-user-messages-inbox-entries-wrapper]';
const REMOVE_ENTRY_URL = '/dashboard/user_messages/##ID##/archive_one';
const REMOVE_ENTRY_METHOD = 'PATCH';
const REMOVE_ENTRY_DELAY = 1050;
const REMOVE_ENTRY_CLASS = 'removed-entry';
const NEW_ENTRY_CLASS = 'new-entry';
const META_SELECTOR = 'meta[name="csrf-token"]';

const REMOVE_CONFIRM_MESSAGE =
  'Are you sure you want to remove this message? You cannot undo this action.';
import UserMessagesInboxEntry from './user_messages_inbox_entry';
import { closest, findMeta } from '../../toolkit/dom';

class UserMessagesInboxEntries {
  container: HTMLElement;
  entries: { [number]: UserMessagesInboxEntry };
  wrapper: HTMLElement;
  csrfToken: string;

  constructor(container: HTMLElement) {
    this.container = container;
    let wrapper = closest(this.container, WRAPPER_SELECTOR);
    if (!(wrapper instanceof HTMLElement)) {
      throw new Error('Unable to locate wrapper element for inbox entries');
    }
    this.wrapper = wrapper;
    this.entries = {};
    this.parse();

    this.csrfToken = findMeta(META_SELECTOR).getAttribute('content');

    this.scrollToBottom();
    this.bindEvents();
  }

  parse() {
    let els = this.container.querySelectorAll('p');

    Array.prototype.forEach.call(els, (el: HTMLElement) => {
      let entry = UserMessagesInboxEntry.parse(el);
      this.entries[entry.id] = entry;
    });
  }

  add(entry: UserMessagesInboxEntry) {
    this.entries[entry.id] = entry;
    let el = entry.getElement();
    el.classList.add(NEW_ENTRY_CLASS);
    this.container.appendChild(el);

    this.scrollToBottom();
  }

  scrollToBottom() {
    this.wrapper.scrollTop = this.wrapper.scrollHeight;
  }

  bindEvents() {
    this.wrapper.addEventListener('click', this.handleRemoveClick.bind(this));
  }

  handleRemoveClick(event: Event) {
    if (!(event.target instanceof HTMLElement)) {
      throw new Error('Invalid context');
    }
    if (event.target.hasAttribute('data-user-messages-remove-message') === false) {
      return;
    }

    if (confirm(REMOVE_CONFIRM_MESSAGE) === false) {
      return;
    }

    let p = closest(event.target, 'p');
    if (!(p instanceof HTMLElement)) {
      throw new Error('Unable to locate removable entry');
    }
    let entry = this.entries[p.dataset.id];
    if (!entry) {
      throw new Error('Entry with this ID is not on the list');
    }

    this.removeEntry(entry);
  }

  removeEntry(entry: UserMessagesInboxEntry) {
    this.sendRemoveRequest(entry.id);

    let p = entry.getElement();
    p.classList.add(REMOVE_ENTRY_CLASS);

    setTimeout(() => {
      this.container.removeChild(p);
    }, REMOVE_ENTRY_DELAY);

    delete this.entries[entry.id];
  }

  sendRemoveRequest(id: number) {
    let request = new XMLHttpRequest();
    request.open('POST', REMOVE_ENTRY_URL.replace('##ID##', id + ''), true);
    request.setRequestHeader('X-CSRF-Token', this.csrfToken);
    request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

    request.onload = () => {
      if (request.status < 200 || request.status >= 400) {
        throw new Error('Unable to remove the message');
      }
    };

    request.onerror = () => {
      throw new Error('Unable to reach server to remove the message');
    };

    request.send(`_method=${REMOVE_ENTRY_METHOD}`);
  }
}

module.exports = UserMessagesInboxEntries;
