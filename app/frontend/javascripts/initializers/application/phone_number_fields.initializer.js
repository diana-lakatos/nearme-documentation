$(document).on('init:phonenumberfieldsform.nearme', function(event, context, options){
  options = options || {};
  require.ensure('../../components/phone_numbers/phone_number_fields_form', function(require){
    var PhoneNumberFieldsForm = require('../../components/phone_numbers/phone_number_fields_form');
    return new PhoneNumberFieldsForm(context, options);
  });
});

$(document).on('init:mobileNumberForm.nearme', function() {
  var container = $('div[data-phone-fields-container]');

  require.ensure(['../../dashboard/modules/phone_numbers', '../../dashboard/forms/selects'], function(require){
    var PhoneNumbers = require('../../dashboard/modules/phone_numbers'),
      customSelects = require('../../dashboard/forms/selects');

    customSelects(container);
    return new PhoneNumbers(container);
  });
});
