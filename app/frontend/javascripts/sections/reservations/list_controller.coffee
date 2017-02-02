module.exports = class ReservationListController

  constructor: (@container, @show_reservation_id) ->
    @animateToReservation()

  animateToReservation: ->
    reservation_container = @container.find("#reservation_#{@show_reservation_id}")
    if reservation_container?
      window.q = reservation_container
      $('html, body').animate
        scrollTop: reservation_container.position().top
        ->
          reservation_container.effect('highlight')
