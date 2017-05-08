// @flow
import { closest } from '../../toolkit/dom';

const SHOULD_SUBMIT_ON_RETURN_ATTRIBUTE =
  'data-user-entry-form-submit-on-return';

class UserEntryTextarea {
  initValue: string;
  shouldSubmitOnReturn: boolean;
  form: HTMLFormElement;
  textarea: HTMLTextAreaElement;

  constructor(textarea: HTMLElement) {
    if (!(textarea instanceof HTMLTextAreaElement)) {
      throw new Error('Invalid or missing textarea element');
    }
    this.textarea = textarea;
    this.initValue = textarea.value;
    this.shouldSubmitOnReturn = this.textarea.hasAttribute(
      SHOULD_SUBMIT_ON_RETURN_ATTRIBUTE
    );

    let form = closest(textarea, 'form');
    if (!(form instanceof HTMLFormElement)) {
      throw new Error(
        'Unable to locate encapsulating form for UserEntryTextarea'
      );
    }
    this.form = form;

    this.bindEvents();
    this.init();
  }

  bindEvents() {
    this.textarea.addEventListener('input', this.adjust.bind(this));
    this.textarea.addEventListener('change', this.adjust.bind(this));
    this.textarea.addEventListener('focus', this.adjust.bind(this));

    if (this.shouldSubmitOnReturn) {
      this.textarea.addEventListener('keydown', this.submitOnReturn.bind(this));
    }
  }

  adjust() {
    if (this.textarea.clientHeight >= this.textarea.scrollHeight) {
      this.textarea.style.height = 'auto';
    }
    if (this.textarea.scrollHeight > 0) {
      this.textarea.style.height = this.textarea.scrollHeight + 2 + 'px';
    }
  }

  submitOnReturn(event: Event) {
    // on enter
    if (event.keyCode === 13)
      if (!event.altKey) {
        event.preventDefault();

        let submitEvent = document.createEvent('Event');
        submitEvent.initEvent('submit', true, true);

        this.form.dispatchEvent(submitEvent);
      } else {
        this.textarea.value = this.textarea.value + '\n';
        this.adjust();
      }
  }

  empty() {
    this.textarea.value = '';
    this.adjust();
  }

  rollback() {
    this.textarea.value = this.initValue;
    this.adjust();
  }

  focus() {
    /* Setting value of textarea moves focus to the end of content */
    let val = this.textarea.value;
    this.textarea.focus();
    this.textarea.value = '';
    this.textarea.value = val;
  }

  value(val: ?string): ?string {
    if (typeof val === 'undefined') {
      return this.textarea.value;
    }

    if (typeof val === 'string') {
      this.textarea.value = val;
      this.adjust();
    }
  }

  init() {
    this.adjust();
  }
}

module.exports = UserEntryTextarea;
