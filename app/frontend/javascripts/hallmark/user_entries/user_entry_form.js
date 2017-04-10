// @flow

import UserEntryTextarea from './user_entry_textarea';
import UserEntryFileField from './user_entry_file_field';
import UserEntryImages from './user_entry_images';
import UserEntryLoader from './user_entry_loader';

type ImageDataType = {
  dataUrl: string,
  orientation: number
};

import { findElement, findTextArea, findInput } from '../../toolkit/dom';

const TEXTAREA_SELECTOR = '[data-user-entry-form-content]';
const FORM_INITIALIZED_ATTRIBUTE = 'data-user-entry-form-initialized';
const SUBMIT_ON_RETURN_ATTRIBUTE = 'data-user-entry-form-submit-on-return';
const ENTRY_IMAGES_SELECTOR = '[data-user-entry-form-images]';
const FILE_FIELD_SELECTOR = '[data-user-entry-form-file]';
const CANCEL_BUTTON_SELECTOR = '[data-cancel-edit]';
const USER_ENTRY_SELECTOR = '[data-user-entry]';

class UserEntryForm {

  form: HTMLFormElement;
  isXHR: boolean;
  mode: 'edit' | 'new';
  target: ?HTMLElement;
  textarea: HTMLTextAreaElement;
  isProcessing: boolean;

  textarea: UserEntryTextarea;
  images: UserEntryImages;
  fileField: UserEntryFileField;
  cancelButton: ?HTMLElement;
  loader: UserEntryLoader;

  boundSubmit: (event: Event) => void;
  boundUpdateImage: (imageData: ImageDataType) => void;
  boundRemoveImage: (event: Event) => void;
  boundCancel: (event: Event) => void;

  constructor() {
    this.boundSubmit = this.submit.bind(this);
    this.boundUpdateImage = this.updateImage.bind(this);
    this.boundRemoveImage = this.removeImage.bind(this);
    this.boundCancel = this.cancel.bind(this);
    this.isProcessing = false;
  }

  setForm(form: HTMLFormElement) {
    if (form.hasAttribute(FORM_INITIALIZED_ATTRIBUTE)) {
      throw new Error('User entry form already initialized');
    }

    this.form = form;
    this.form.setAttribute(FORM_INITIALIZED_ATTRIBUTE, 'true');
    this.isXHR = form.hasAttribute('data-user-entry-form-remote');
    this.mode = form.hasAttribute('data-user-entry-edit-mode') ? 'edit' : 'new';

    let entryFormTargetSelector = form.dataset.userEntryFormTarget;

    if (this.isXHR && !entryFormTargetSelector) {
      throw new Error(`Missing or invalid entryFormTargetSelector: ${entryFormTargetSelector}`);
    }
    else if (this.isXHR) {
      this.target = findElement(entryFormTargetSelector);
    }

    let textarea = findTextArea(TEXTAREA_SELECTOR, form);
    this.textarea = new UserEntryTextarea(textarea, { submitOnReturn: textarea.hasAttribute(SUBMIT_ON_RETURN_ATTRIBUTE) });
    this.images = new UserEntryImages(findElement(ENTRY_IMAGES_SELECTOR, form));
    this.fileField = new UserEntryFileField(findInput(FILE_FIELD_SELECTOR, form));
    this.cancelButton = form.querySelector(CANCEL_BUTTON_SELECTOR);

    this.loader = new UserEntryLoader();
    this.form.appendChild(this.loader.getElement());
    this.bindEvents();
  }

  unbindEvents() {
    this.form.removeEventListener('submit', this.boundSubmit);
    this.fileField.off('change', this.boundUpdateImage);
    this.images.off('remove', this.boundRemoveImage);
  }

  submit(event: Event) {

    if (this.isProcessing) {
      event.preventDefault();
      return;
    }

    /* Do not submit if the content area is empty */
    if (!this.textarea.value()) {
      event.preventDefault();
      return;
    }

    /* Make sure data is fetched before we disable the textarea. Otherwise it won't be sent */
    let data = new FormData(this.form);

    this.enableProcessing();

    if (!this.isXHR) {
      return;
    }

    event.preventDefault();

    $.ajax({
      url: this.form.action,
      method: 'POST',
      data: data,
      dataType: 'html',
      contentType: false,
      cache: false,
      processData: false
    })
    .done(this.process.bind(this))
    .fail(() => {
      alert('We couldn’t create this content. Please try again');
      this.disableProcessing();
      throw new Error(`Unable to create content ${this.form.action}`);
    });
  }

  process(html: string) {
    let target = this.target;
    if (!(target instanceof HTMLElement)) {
      throw new Error('Missing target element for form');
    }

    if (this.mode === 'edit') {
      target.innerHTML = $(html).html();
      target.classList.remove('is-active');
      $(target).closest(USER_ENTRY_SELECTOR).trigger('update');
    } else {
      target.insertAdjacentHTML('afterbegin', html);
      let newEntry = target.querySelector(USER_ENTRY_SELECTOR);
      if (newEntry) {
        newEntry.classList.add('new-entry');
      }

      this.empty();
    }

    this.disableProcessing();

    $(document).trigger('new-comment');
  }

  updateImage(imageData: ImageDataType) {
    this.images.removeAll();

    if (imageData.dataUrl) {
      this.images.add(imageData);
    }

    this.textarea.focus();
  }

  enableProcessing() {
    this.form.classList.add('processing');
    this.loader.enable();
    Array.prototype.forEach.call(this.form.querySelectorAll('[type="submit"]'), (el: HTMLButtonElement) => {
      el.dataset.initialDisabledState = el.disabled ? 'yes' : 'no';
      el.setAttribute('disabled', 'disabled');
    });
    this.isProcessing = true;
  }

  disableProcessing() {
    this.form.classList.remove('processing');
    this.loader.disable();
    Array.prototype.forEach.call(this.form.querySelectorAll('[type="submit"]'), (el: HTMLButtonElement) => {
      if (el.dataset.initialDisabledState === 'yes') {
        el.removeAttribute('disabled');
      }
    });
    this.isProcessing = false;
  }

  empty() {
    this.textarea.empty();
    this.fileField.empty();
    this.images.removeAll();
  }

  removeImage() {
    this.fileField.empty();
  }

  bindEvents() {
    this.form.addEventListener('submit', this.boundSubmit);
    this.fileField.on('change', this.boundUpdateImage);
    this.images.on('remove', this.boundRemoveImage);

    if (this.cancelButton instanceof HTMLElement) {
      this.cancelButton.addEventListener('click', this.boundCancel);
    }
  }

  cancel() {
    this.images.rollback();
    this.fileField.empty();
    this.textarea.rollback();
  }

  build() {

  }
}

module.exports = UserEntryForm;
