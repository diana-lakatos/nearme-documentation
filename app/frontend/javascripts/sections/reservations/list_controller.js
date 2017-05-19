var ReservationListController;

ReservationListController = function() {
  function ReservationListController(container, show_reservation_id) {
    this.container = container;
    this.show_reservation_id = show_reservation_id;
    this.animateToReservation();
  }

  ReservationListController.prototype.animateToReservation = function() {
    var reservation_container;
    reservation_container = this.container.find('#reservation_' + this.show_reservation_id);
    if (reservation_container != null) {
      window.q = reservation_container;
      return $(
        'html, body'
      ).animate({ scrollTop: reservation_container.position().top }, function() {
        return reservation_container.effect('highlight');
      });
    }
  };

  return ReservationListController;
}();

module.exports = ReservationListController;
