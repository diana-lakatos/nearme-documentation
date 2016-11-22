var els = $('[data-complete-reservation]');
if (els.length > 0) {
  require.ensure('../../dashboard/controllers/complete_reservation_controller', function(require){
    var CompleteReservationController = require('../../dashboard/controllers/complete_reservation_controller');
    els.each(function(){
      return new CompleteReservationController(this);
    });
  });
}
