// @flow
const LIST_SELECTOR = '[data-user-messages-contact-list]';
const TOGGLER_SELECTOR = '[data-user-messages-contact-list-toggler]';
const ACTIVE_CLASS = 'active';
import { findElement, closest } from '../../toolkit/dom';
import Hammer from 'hammerjs';

class UserMessagesInboxContactList {
  container: HTMLElement;
  list: HTMLElement;
  toggler: HTMLButtonElement;

  constructor(container: HTMLElement) {
    this.container = container;
    this.list = findElement(LIST_SELECTOR, this.container);

    let toggler = this.container.querySelector(TOGGLER_SELECTOR);

    /* Toggler exists, we are in the conversation view */
    if (toggler instanceof HTMLButtonElement) {
      this.toggler = toggler;
      this.bindEvents();
      this.bindSwipeEvents();
    } else {
      /* There is no toggler, we want to force visibility of the contact list */
      this.enable();
    }
  }

  bindEvents() {
    let body = document.querySelector('body');
    if (!body) {
      throw new Error('Invalid environment, <body> not found');
    }

    body.addEventListener('click', (event: Event) => {
      if (event.defaultPrevented) {
        return;
      }
      if (!closest(event.target, LIST_SELECTOR)) {
        this.disable();
      }
    });

    this.toggler.addEventListener('click', (event: Event) => {
      event.preventDefault();
      this.enable();
    });
  }

  enable() {
    this.list.classList.add(ACTIVE_CLASS);
  }

  disable() {
    this.list.classList.remove(ACTIVE_CLASS);
  }

  bindSwipeEvents() {
    let hm = new Hammer.Manager(this.list);

    hm.add(new Hammer.Swipe({ direction: Hammer.DIRECTION_LEFT, threshold: 50 }));

    hm.on('swipe', this.disable.bind(this));
  }
}

module.exports = UserMessagesInboxContactList;
