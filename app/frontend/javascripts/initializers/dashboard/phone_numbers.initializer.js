var els = $('[data-phone-fields-container]');
if (els.length > 0) {
  require.ensure('../../dashboard/modules/phone_numbers', function(require) {
    var PhoneNumbers = require('../../dashboard/modules/phone_numbers');
    return new PhoneNumbers();
  });
}
