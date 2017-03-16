// @flow
let els = document.querySelectorAll('[data-phone-fields-container]');

if (els.length > 0) {
  require.ensure('../phone_number_country_codes', (require) => {
    const PhoneNumberCountryCodes = require('../phone_number_country_codes');

    Array.prototype.forEach.call(els, (container) => {
      new PhoneNumberCountryCodes(container);
    });
  });
}
