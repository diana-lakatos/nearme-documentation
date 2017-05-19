// @flow

const ACTIVE_WRAPPER_CLASS = 'active';

import { findSelect, findInput, findElement } from '../../toolkit/dom';
import ValidatableFieldCollection from '../../toolkit/form_validation/validatable_field_collection';

class NotificationPreferencesForm {
  validator: ValidatableFieldCollection;
  form: HTMLFormElement;
  smsNotificationField: HTMLInputElement;
  countryField: HTMLSelectElement;
  mobilePhoneField: HTMLInputElement;
  mobilePhoneWrapper: HTMLElement;

  constructor(form: HTMLFormElement) {
    this.form = form;

    this.smsNotificationField = findInput('[data-sms-notification]', this.form);
    this.countryField = findSelect('[data-country-selector]', this.form);
    this.mobilePhoneField = findInput('[data-mobile-number]', this.form);
    this.mobilePhoneWrapper = findElement('[data-sms-notifications-required-fields]', this.form);

    this.validator = this.setupValidations();

    this.bindEvents();
  }

  setupValidations(): ValidatableFieldCollection {
    let validator = new ValidatableFieldCollection();

    validator.addField(this.countryField, [
      {
        type: 'required',
        message: 'Select your country',
        condition: (): boolean => this.smsNotificationField.checked
      }
    ]);

    validator.addField(this.mobilePhoneField, [
      {
        type: 'required',
        message: 'Enter your phone number',
        condition: (): boolean => this.smsNotificationField.checked
      },
      {
        type: 'phone_number',
        message: 'Invalid phone number',
        condition: (): boolean => this.smsNotificationField.checked
      }
    ]);

    return validator;
  }

  bindEvents() {
    this.form.addEventListener('submit', this.handleSubmit.bind(this));
    this.smsNotificationField.addEventListener('change', this.handleToggleSwitch.bind(this));
  }

  handleToggleSwitch() {
    if (this.smsNotificationField.checked) {
      this.mobilePhoneWrapper.classList.add(ACTIVE_WRAPPER_CLASS);
    } else {
      this.mobilePhoneWrapper.classList.remove(ACTIVE_WRAPPER_CLASS);
    }
  }

  handleSubmit(event: Event) {
    event.preventDefault();

    this.validator
      .process()
      .then(() => {
        this.form.submit();
      })
      .catch((message: string) => {
        throw new Error(message);
      });
  }
}

module.exports = NotificationPreferencesForm;
