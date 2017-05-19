// @flow
const api = require('../../modules/api');
const newSessionUrl = '/api/sessions';

class LoginForm {
  uiForm: HTMLFormElement;
  uiEmail: HTMLInputElement;
  uiPassword: HTMLInputElement;
  uiRemember: HTMLInputElement;

  constructor(form: HTMLFormElement) {
    this.uiForm = form;

    let uiEmail = form.querySelector('[data-login-form-email]');
    if (!(uiEmail instanceof HTMLInputElement)) {
      throw new Error('Login Form :: Missing or invalid email field');
    }
    this.uiEmail = uiEmail;

    let uiPassword = form.querySelector('[data-login-form-password]');
    if (!(uiPassword instanceof HTMLInputElement)) {
      throw new Error('Login Form :: Missing or invalid password field');
    }
    this.uiPassword = uiPassword;

    this.bindEvents();
  }

  bindEvents() {
    this.uiForm.addEventListener('submit', (e: Event) => {
      e.preventDefault();
      if (this.validate()) {
        this.submit();
      }
    });

    this.uiEmail.addEventListener('change', this.validateEmail.bind(this));
    this.uiPassword.addEventListener('change', this.validatePassword.bind(this));
  }

  submit() {
    api
      .post(newSessionUrl, this.getFormData())
      .then((result: { data: { attributes: { token: string } } }) => {
        window.location = `/admin/?token=${result.data.attributes.token}`;
      })
      .catch(() => {
        this.setError(this.uiEmail, 'Invalid email or password');
      });
  }

  getFormData(): { email: string, password: string } {
    return { email: this.uiEmail.value, password: this.uiPassword.value };
  }

  validateEmail(): boolean {
    let email: string = this.uiEmail.value;

    this.resetFieldUI(this.uiEmail);

    if (email === '') {
      this.setError(this.uiEmail, 'Fill in your email');
      return false;
    }

    if (this.validateEmailSyntax(email) === false) {
      this.setError(this.uiEmail, 'Invalid email address');
      return false;
    }

    return true;
  }

  validatePassword(): boolean {
    let password: string = this.uiPassword.value;

    this.resetFieldUI(this.uiPassword);

    if (password === '') {
      this.setError(this.uiPassword, 'Fill in your password');
      return false;
    }

    return true;
  }

  validate(): boolean {
    let flag = true;
    if (this.validateEmail() === false) {
      flag = false;
    }
    if (this.validatePassword() === false) {
      flag = false;
    }
    return flag;
  }

  resetFieldUI(field: HTMLElement) {
    let parent = field.parentNode;
    if (!(parent instanceof HTMLElement)) {
      return;
    }
    parent.classList.remove('has-error');

    function removeElement(el: HTMLElement) {
      if (el.parentNode) {
        el.parentNode.removeChild(el);
      }
    }

    Array.prototype.forEach.call(parent.querySelectorAll('strong.form-error'), removeElement);
  }

  setError(field: HTMLElement, message: string) {
    let err = document.createElement('strong');
    err.classList.add('form-error');
    err.innerHTML = message;
    field.insertAdjacentElement('afterend', err);

    if (field.parentNode instanceof HTMLElement) {
      field.parentNode.classList.add('has-error');
    }
  }

  validateEmailSyntax(str: string): boolean {
    return /^[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,6}$/i.test(str);
  }
}

module.exports = LoginForm;
