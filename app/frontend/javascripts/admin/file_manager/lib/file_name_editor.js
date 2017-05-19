const ENABLED_EDIT_CLASS = 'file-name-edit--enabled';
const INPUT_SELECTOR = '[data-file-name-input]';

class FileNameEditor {
  constructor(container) {
    this._ui = {};
    this._ui.container = container;
    this._ui.form = container.querySelector('[data-file-name-form]');
    this._ui.stringHolder = container.querySelector('[data-file-name-string]');
    this._ui.textWrapper = container.querySelector('[data-file-name-text-wrapper]');
    this._ui.input = this._ui.form.querySelector(INPUT_SELECTOR);

    this._initialValue = this._ui.input.value;

    this._bindEvents();
  }

  _bindEvents() {
    this._ui.textWrapper.addEventListener('click', e => {
      e.stopPropagation();
      e.preventDefault();
      this.enableEditMode();
    });

    this._ui.input.addEventListener('blur', () => {
      this.save();
    });

    this._ui.input.addEventListener('keydown', e => {
      if (e.keyCode === 27) {
        this.cancel();
      }
    });

    this._ui.form.addEventListener('submit', e => {
      e.preventDefault();
      this.save();
    });
  }

  enableEditMode(refocus = true) {
    this._ui.container.classList.add(ENABLED_EDIT_CLASS);

    if (refocus) {
      this._activeElement = document.activeElement;
      this._ui.input.focus();
    }

    /* Select name without extension */
    let lastDot = this._ui.input.value.lastIndexOf('.');
    this._ui.input.setSelectionRange(0, lastDot > -1 ? lastDot : this._ui.input.value.length);
  }

  disableEditMode() {
    this._ui.container.classList.remove(ENABLED_EDIT_CLASS);
    this._activeElement.focus();
  }

  cancel() {
    this._reset();
    this._clearErrors();
    this.disableEditMode();
  }

  validate() {
    let flag = true;
    let value = this._ui.input.value;

    if (!value) {
      this._showError('File name is required');
      flag = false;
    }

    //TODO: Format validation
    //TODO: unique name validation
    return flag;
  }

  save() {
    this._clearErrors();

    if (this.validate()) {
      this._setValue(this.currentValue());
      this._sendForm();
      this.disableEditMode();
    }
  }

  _setValue(value) {
    this._ui.stringHolder.innerText = value;
    this._ui.input.value = value;
  }

  currentValue() {
    return this._ui.input.value;
  }

  _reset() {
    this._setValue(this._initialValue);
  }

  _clearErrors() {
    let errors = this._ui.container.querySelectorAll('strong.error');
    for (let error of errors) {
      error.parentNode.removeChild(error);
    }
  }

  _showError(message) {
    let error = document.createElement('strong');
    error.className = 'error';
    error.innerHTML = message;

    this._ui.container.appendChild(error);
  }

  _sendForm() {
    let result = true;
    // TODO: XHR to the server goes here
    if (result) {
      // success callback
      this._initialValue = this.currentValue();
    } else {
      // fail callback
      this._reset();
      this.enableEditMode(false);
      this._showError('Unable to change the file name');
    }
  }
}

module.exports = FileNameEditor;
