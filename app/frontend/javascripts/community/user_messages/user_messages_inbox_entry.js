// @flow
import timeago from 'timeago.js';
const META_SELECTOR = '[data-user-messages-meta]';
const AUTHOR_SELECTOR = '[data-user-messages-meta-author]';
const TIME_SELECTOR = 'time';
const OWN_MESSAGE_CLASS = 'own-message';
const ATTACHMENT_CLASS = 'attachment';

import { findElement } from '../../toolkit/dom';

class UserMessagesInboxEntry {
  element: HTMLElement;
  author: string;
  time: Date;
  attachment: { name: string, url: string };
  body: ?string;
  isOwnMessage: boolean;

  constructor() {
    this.time = new Date();
    this.isOwnMessage = false;
  }

  getElement(): HTMLElement {
    if (this.element) {
      return this.element;
    }

    return this.build();
  }

  build(): HTMLElement {
    let element = document.createElement('p');

    if (this.isOwnMessage) {
      element.classList.add(OWN_MESSAGE_CLASS);
    }

    if (this.author) {
      let meta = document.createElement('span');
      meta.classList.add('meta');
      meta.setAttribute('data-user-messages-meta', '');
      meta.innerHTML = `<span data-user-messages-meta-author>${this.author}</span> <time datetime="${this.time.getTime()}">${this.getFormattedTime()}</time> says:`;

      let time = findElement(TIME_SELECTOR, meta);
      new timeago().render(time);

      element.appendChild(meta);
    }

    if (this.attachment) {
      element.classList.add(ATTACHMENT_CLASS);
      let body = `Attachment: <a href="${this.attachment.url}">${this.attachment.name}</a>`;
      element.insertAdjacentHTML('beforeend', body);
    }

    if (this.body) {
      element.insertAdjacentHTML('beforeend', this.body);
    }

    this.element = element;

    return this.element;
  }

  getFormattedTime(): string {
    return timeago().format(this.time);
  }

  setElement(el: HTMLElement) {
    this.element = el;
  }

  setAuthor(author: string) {
    this.author = author;
  }

  setTime(time: Date) {
    this.time = time;
  }

  setBody(body: string) {
    this.body = body;
  }

  setOwnMessage(isOwnMessage: boolean) {
    this.isOwnMessage = isOwnMessage;
  }

  setAttachment(name: string, url: string) {
    this.attachment = { name: name, url: url };
  }

  static parse(el: HTMLElement): UserMessagesInboxEntry {
    let meta = el.querySelector(META_SELECTOR);
    let entry = new UserMessagesInboxEntry();
    entry.setElement(el);

    if (meta instanceof HTMLElement) {
      let author = findElement(AUTHOR_SELECTOR, meta);
      entry.setAuthor(author.innerHTML);

      let time = findElement(TIME_SELECTOR, meta);
      entry.setTime(new Date(time.getAttribute('datetime')));
      new timeago().render(time);
    }

    entry.setOwnMessage(el.classList.contains(OWN_MESSAGE_CLASS));

    if (el.classList.contains(ATTACHMENT_CLASS)) {
      let link = findElement('a', el);
      entry.setAttachment(link.innerHTML, link.getAttribute('href'));
    } else {
      entry.setBody(this.parseBody(el));
    }

    return entry;
  }

  static parseBody(el: HTMLElement): string {
    if (!el.querySelector(META_SELECTOR)) {
      return el.innerHTML;
    }
    /* We have to get rid of the meta selector when fetching message body, but can't modify actual content */
    let clone = el.cloneNode(true);
    let meta = findElement(META_SELECTOR, clone);
    clone.removeChild(meta);
    return clone.innerHTML;
  }
}

module.exports = UserMessagesInboxEntry;
