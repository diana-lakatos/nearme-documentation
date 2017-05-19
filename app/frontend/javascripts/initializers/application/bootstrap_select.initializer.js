$(document).on('init:selectpicker.nearme', function() {
  require.ensure('../../components/forms/bootstrap_select_initializer', function(require) {
    var BootstrapSelectInitializer = require('../../components/forms/bootstrap_select_initializer');
    return new BootstrapSelectInitializer($('.selectpicker'), { iconShow: false });
  });
});

$(document).on('nested:fieldAdded', function(event) {
  require.ensure('../../components/forms/bootstrap_select_initializer', function(require) {
    var BootstrapSelectInitializer = require('../../components/forms/bootstrap_select_initializer');
    return new BootstrapSelectInitializer(event.field.find('.selectpicker'), { iconShow: false });
  });
});

var els = $('.selectpicker');
if (els.length > 0) {
  require.ensure('../../components/forms/bootstrap_select_initializer', function(require) {
    var BootstrapSelectInitializer = require('../../components/forms/bootstrap_select_initializer');
    return new BootstrapSelectInitializer(els, { iconShow: false });
  });
}
