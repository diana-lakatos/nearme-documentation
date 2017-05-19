var els = $('[data-booking-type-list]');
if (els.length > 0) {
  require.ensure('../../dashboard/listings/booking_type', function(require) {
    var BookingType = require('../../dashboard/listings/booking_type');
    els.each(function() {
      return new BookingType(this);
    });
  });
}
