// @flow
import { closest } from '../../../toolkit/dom';
import UserEntryEditor from './user_entry_editor';

class UserEntryEditorTextarea extends UserEntryEditor{
  shouldSubmitOnReturn: boolean;
  form: HTMLFormElement;

  constructor(textarea: HTMLTextAreaElement) {
    super(textarea);

    this.shouldSubmitOnReturn = this.textarea.hasAttribute('data-user-entry-form-submit-on-return');
    let form = closest(textarea, 'form');
    if (!(form instanceof HTMLFormElement)) {
      throw new Error('Unable to find form element for UserEntryEditorTextarea');
    }

    this.form = form;

    this.bindEvents();
    this.adjust();
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
      this.textarea.style.height = (this.textarea.scrollHeight + 2) + 'px';
    }
  }

  submitOnReturn(event: Event) {

    if (event.keyCode !== 13) {
      return;
    }

    if (event.altKey) {
      this.textarea.value = this.textarea.value + '\n';
      this.adjust();
      return;
    }

    event.preventDefault();

    let submitEvent = document.createEvent('Event');
    submitEvent.initEvent('submit', true, true);

    this.form.dispatchEvent(submitEvent);
  }

  empty() {
    super.empty();
    this.adjust();
  }

  rollback() {
    super.rollback();
    this.adjust();
  }

  setValue(val: string) {
    super.setValue(val);
    this.adjust();
  }
}

module.exports = UserEntryEditorTextarea;
