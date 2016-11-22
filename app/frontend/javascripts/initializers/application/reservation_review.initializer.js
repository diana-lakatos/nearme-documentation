var el = $('#checkout-form');
if (el.length > 0) {
  require.ensure('../../sections/reservations/review_controller', function(require){
    var ReservationReviewController = require('../../sections/reservations/review_controller');
    return new ReservationReviewController(el);
  });
}

