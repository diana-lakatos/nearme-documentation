// @flow

import { findSelect, findInput } from '../toolkit/dom';

class PhoneNumberCountryCodes {
  container: HTMLElement
  countrySelector: HTMLSelectElement;
  mobileNumberField: HTMLInputElement;
  prefixContainer: HTMLElement;

  constructor(container: HTMLElement) {
    this.container = container;
    this.countrySelector = findSelect('[data-country-selector]', this.container);
    this.mobileNumberField = findInput('[data-mobile-number]', this.container);
    let prefix = this.mobileNumberField.previousElementSibling;
    if (!(prefix instanceof HTMLElement)) {
      throw new Error('Unable to locate mobile number prefix container');
    }
    this.prefixContainer = prefix;
    this.bindEvents();
  }

  bindEvents() {
    this.countrySelector.addEventListener('change', this.handleCountryChange.bind(this));
  }

  handleCountryChange() {
    if (this.countrySelector.selectedIndex === -1) {
      this.updateCountryCode();
      return;
    }

    let selectedOption = this.countrySelector.options[this.countrySelector.selectedIndex];
    if (selectedOption instanceof HTMLElement) {
      this.updateCountryCode(selectedOption.dataset.callingCode);
    }
  }

  updateCountryCode(code: ?string) {
    this.prefixContainer.innerHTML = code ? `+${code}` : '-';
  }
}

module.exports = PhoneNumberCountryCodes;
