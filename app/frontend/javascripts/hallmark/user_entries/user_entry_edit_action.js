// @flow
import Eventable from '../../toolkit/eventable';
import { findElement } from '../../toolkit/dom';

const TARGET_SELECTOR = '.entry-content-a';

class UserEntryEditAction extends Eventable {
  container: HTMLElement;
  trigger: HTMLElement;
  target: HTMLElement;

  constructor(trigger: HTMLElement, container: HTMLElement) {
    super();

    this.trigger = trigger;
    this.container = container;
    this.target = findElement(TARGET_SELECTOR, container);

    this.bindEvents();
  }

  bindEvents() {
    this.trigger.addEventListener('click', (e: Event) => {
      e.preventDefault();
      this.toggleEditor();
    });
  }

  toggleEditor() {
    this.emit('toggle');
    if (this.target.classList.contains('is-active')) {
      this.hideEditor();
      return;
    }
    this.showEditor();
  }

  hideEditor() {
    this.target.classList.remove('is-active');
  }

  showEditor() {
    this.target.classList.add('is-active');
    let textarea = this.target.querySelector('textarea');
    if (!(textarea instanceof HTMLTextAreaElement)) {
      throw new Error('Unable to locate textarea element');
    }
    textarea.focus();

    let focusEvent = document.createEvent('Event');
    focusEvent.initEvent('focus', true, true);
    textarea.dispatchEvent(focusEvent);
  }

}

module.exports = UserEntryEditAction;
