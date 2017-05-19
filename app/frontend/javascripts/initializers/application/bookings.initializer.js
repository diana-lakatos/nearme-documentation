var els = $('[data-toggleable-booking-module]');
if (els.length > 0) {
  require.ensure('../../sections/bookings/controller', function(require) {
    var BookingsController = require('../../sections/bookings/controller');
    els.each(function() {
      return new BookingsController(this);
    });
  });
}

$(document).on('init:bookingscontroller.nearme', function(event, el) {
  require.ensure(
    [
      '../../sections/bookings/controller',
      '../../components/custom_inputs',
      '../../components/custom_selects'
    ],
    function(require) {
      var BookingsController = require('../../sections/bookings/controller'),
        CustomInputs = require('../../components/custom_inputs'),
        CustomSelects = require('../../components/custom_selects');

      new BookingsController(el);
      new CustomInputs(el);
      new CustomSelects(el);
    }
  );
});

var el = $('.booking-module-container');
if (el.length > 0) {
  el.on('click', '.pricing-tabs a', function(e) {
    e.preventDefault();
    $(e.target).closest('a').tab('show');
  });
  el.find('.pricing-tabs a.possible:first').click();
}
