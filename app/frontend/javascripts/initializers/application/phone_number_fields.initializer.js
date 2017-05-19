$(document).on('init:phonenumberfieldsform.nearme', function(event, context, options) {
  options = options || {};
  require.ensure('../../components/phone_numbers/phone_number_fields_form', function(require) {
    var PhoneNumberFieldsForm = require('../../components/phone_numbers/phone_number_fields_form');
    return new PhoneNumberFieldsForm(context, options);
  });
});
