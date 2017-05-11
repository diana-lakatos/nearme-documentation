// @flow
type CommentTextareaOptionsType = {
  submitOnEnter?: boolean,
  form?: HTMLFormElement,
  autoadjust?: boolean
};

const DEFAULTS = {
  submitOnEnter: true,
  autoadjust: true
};

import { closest } from '../../toolkit/dom';

class CommentTextarea {

  options: CommentTextareaOptionsType;
  textarea: HTMLTextAreaElement;
  form: HTMLFormElement;
  initValue: string;

  constructor(textarea: HTMLTextAreaElement, options: CommentTextareaOptionsType = {}) {
    this.textarea = textarea;
    this.options = Object.assign({}, DEFAULTS, options);

    this.initValue = this.textarea.value;

    if (!this.options.form) {
      let form = closest(this.textarea, 'form');
      if (!(form instanceof HTMLFormElement)) {
        throw new Error('Unable to locate binding form for textarea');
      }
      this.form = form;
    }
    else {
      this.form = this.options.form;
    }

    this.bindEvents();
    this.adjust();
  }

  bindEvents() {
    this.textarea.addEventListener('input', this.adjust.bind(this));
    this.textarea.addEventListener('change', this.adjust.bind(this));
    this.textarea.addEventListener('focus', this.adjust.bind(this));

    if (this.options.submitOnEnter) {
      this.textarea.addEventListener('keydown', this.submitOnEnter.bind(this));
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

  submitOnEnter(event: KeyboardEvent) {
    // non enter key pressed, go on, nothing to see here
    if (event.keyCode !== 13) {
      return;
    }

    // enter pressed, we want custom actions instead of default support
    event.preventDefault();

    // alt pressed, we want a newline, not submit
    if (event.altKey) {
      this.textarea.value = this.textarea.value + '\n';
      this.adjust();
      return;
    }

    // enter pressed, no alt, but textarea is empty or whitespace, stop right here
    if (this.textarea.value.trim() === '') {
      return;
    }

    // enter pressed, no alt, our textarea has content - bam! we can submit form
    let submitEvent = document.createEvent('Event');
    submitEvent.initEvent('submit', true, true);
    this.form.dispatchEvent(submitEvent);
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

  getValue(): string {
    return this.textarea.value;
  }

  setValue(value: string) {
    this.textarea.value = value;
    this.adjust();
  }
}

module.exports = CommentTextarea;
