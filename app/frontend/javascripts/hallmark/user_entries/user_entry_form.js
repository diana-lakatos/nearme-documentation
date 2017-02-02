const UserEntryTextarea = require('./user_entry_textarea');
const UserEntryFileField = require('./user_entry_file_field');
const UserEntryImages = require('./user_entry_images');
const UserEntryLoader = require('./user_entry_loader');

class UserEntryForm {
  constructor() {
    this.ui = {};
    this.bound = {};
    this.bound.submit = this.submit.bind(this);
    this.bound.updateImage = this.updateImage.bind(this);
    this.bound.removeImage = this.removeImage.bind(this);
    this.bound.cancel = this.cancel.bind(this);
  }

  setForm(form) {
    if (form.hasAttribute('data-user-entry-form-initialized')) {
      throw new Error('User entry form already initialized');
    }

    this.ui.form = form;
    this.ui.form.dataset.userEntryFormInitialized = true;
    this.isXhr = !!form.hasAttribute('data-user-entry-form-remote');
    this.mode = form.hasAttribute('data-user-entry-edit-mode') ? 'edit' : 'new';
    this.ui.target = document.querySelector(form.dataset.userEntryFormTarget);
    this.textarea = new UserEntryTextarea(form.querySelector('[data-user-entry-form-content]'));
    this.images = new UserEntryImages(form.querySelector('[data-user-entry-form-images]'));
    this.fileField = new UserEntryFileField(form.querySelector('[data-user-entry-form-file]'));
    this.ui.cancelButton = this.ui.form.querySelector('[data-cancel-edit]');

    this.loader = new UserEntryLoader();
    this.ui.form.appendChild(this.loader.getElement());
    this.bindEvents();
  }

  unbindEvents() {
    this.ui.form.removeEventListener('submit', this.bound.submit);
    this.fileField.off('change', this.bound.updateImage);
    this.images.off('remove', this.bound.removeImage);
  }

  submit(event) {
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
    let data = new FormData(this.ui.form);

    this.enableProcessing();

    if (!this.isXhr) {
      return;
    }

    event.preventDefault();

    $.ajax({
      url: this.ui.form.action,
      method: 'POST',
      data: data,
      dataType: 'html',
      contentType: false,
      cache: false,
      processData: false
    }).done(this.process.bind(this)).fail(() => {
      alert('We couldn’t create this content. Please try again');
      this.disableProcessing();
      throw new Error(`Unable to create content ${this.ui.form.action}`);
    });
  }

  process(html) {
    if (this.mode === 'edit') {
      this.ui.target.innerHTML = html;
      this.ui.target.classList.remove('is-active');
      $(this.ui.target).closest('[data-user-entry]').trigger('update');
    } else {
      this.ui.target.insertAdjacentHTML('afterbegin', html);
      let newEntry = this.ui.target.querySelector('[data-user-entry]');
      if (newEntry) {
        newEntry.classList.add('new-entry');
      }

      this.empty();
    }

    this.disableProcessing();

    $(document).trigger('new-comment');
  }

  updateImage(imageData = {}) {
    this.images.removeAll();

    if (imageData.dataUrl) {
      this.images.add(imageData.dataUrl);
    }

    this.textarea.focus();
  }

  enableProcessing() {
    this.ui.form.classList.add('processing');
    this.loader.enable();
    Array.prototype.forEach.call(this.ui.form.querySelectorAll('[type="submit"]'), (el) => {
      el.dataset.initialDisabledState = el.disabled ? 'yes' : 'no';
      el.setAttribute('disabled', 'disabled');
    });
    this.isProcessing = true;
  }

  disableProcessing() {
    this.ui.form.classList.remove('processing');
    this.loader.disable();
    Array.prototype.forEach.call(this.ui.form.querySelectorAll('[type="submit"]'), (el) => {
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
    this.ui.form.addEventListener('submit', this.bound.submit);
    this.fileField.on('change', this.bound.updateImage);
    this.images.on('remove', this.bound.removeImage);

    if (this.ui.cancelButton) {
      this.ui.cancelButton.addEventListener('click', this.bound.cancel);
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
