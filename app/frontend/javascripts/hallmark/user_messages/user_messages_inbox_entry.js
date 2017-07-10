// @flow
import timeago from 'timeago.js';
const META_SELECTOR = '[data-user-messages-meta]';
const AUTHOR_SELECTOR = '[data-user-messages-meta-author]';
const TIME_SELECTOR = 'time';
const OWN_MESSAGE_CLASS = 'own-message';
const ATTACHMENT_CLASS = 'attachment';
const MESSAGE_BODY_SELECTOR = '.body';

import { findElement } from '../../toolkit/dom';

class UserMessagesInboxEntry {
  element: HTMLElement;
  id: number;
  author: string;
  time: Date;
  attachments: Array<{ name: string, url: string }>;
  body: ?string;
  isOwnMessage: boolean;

  constructor() {
    this.time = new Date();
    this.isOwnMessage = false;
    this.attachments = [];
  }

  getElement(): HTMLElement {
    if (this.element) {
      return this.element;
    }

    return this.build();
  }

  build(): HTMLElement {
    let element = document.createElement('p');

    element.dataset.id = this.id + '';

    if (this.author) {
      let meta = document.createElement('span');
      meta.classList.add('meta');
      meta.setAttribute('data-user-messages-meta', '');
      meta.innerHTML = `<span data-user-messages-meta-author>${this.author}</span> <time datetime="${this.time.getTime()}">${this.getFormattedTime()}</time> says:`;

      let time = findElement(TIME_SELECTOR, meta);
      new timeago().render(time);

      element.appendChild(meta);
    }

    if (this.body) {
      element.insertAdjacentHTML('beforeend', `<span class="body">${this.body}</span>`);
    }

    this.attachments.forEach((attachment: { name: string, url: string }) => {
      element.insertAdjacentHTML(
        'beforeend',
        `<span class="attachment"><a href="${attachment.url}">${attachment.name}</a></span>`
      );
    });

    if (this.isOwnMessage) {
      element.classList.add(OWN_MESSAGE_CLASS);
      element.insertAdjacentHTML(
        'beforeend',
        '<button type="button" class="remove-message" data-user-messages-remove-message>Remove this message</button>'
      );
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

  getId(): number {
    return this.id;
  }

  setId(id: number) {
    this.id = id;
  }

  setOwnMessage(isOwnMessage: boolean) {
    this.isOwnMessage = isOwnMessage;
  }

  addAttachment(name: string, url: string) {
    this.attachments.push({ name: name, url: url });
  }

  static parse(el: HTMLElement): UserMessagesInboxEntry {
    let meta = el.querySelector(META_SELECTOR);
    let entry = new UserMessagesInboxEntry();
    entry.setElement(el);
    entry.setId(parseInt(el.dataset.id, 10));

    if (meta instanceof HTMLElement) {
      let author = findElement(AUTHOR_SELECTOR, meta);
      entry.setAuthor(author.innerHTML);

      let time = findElement(TIME_SELECTOR, meta);
      entry.setTime(new Date(time.getAttribute('datetime')));
      new timeago().render(time);
    }

    entry.setOwnMessage(el.classList.contains(OWN_MESSAGE_CLASS));

    Array.prototype.forEach.call(
      el.querySelectorAll(`.${ATTACHMENT_CLASS} a`),
      (link: HTMLElement) => {
        let url = link.getAttribute('href') || '';
        entry.addAttachment(link.innerHTML, url);
      }
    );

    let body = el.querySelector(MESSAGE_BODY_SELECTOR);
    if (body instanceof HTMLElement) {
      entry.setBody(body.innerHTML);
    }

    return entry;
  }
}

module.exports = UserMessagesInboxEntry;
