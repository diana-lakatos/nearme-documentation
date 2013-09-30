# Controller for handling each reservation in my bookings page
#
# The controller is initialized with the reservation DOM container. 
class @Reservation.UserReservationController

  constructor: (@container, @options = {}) ->
    @dates = @container.find('a.dates')
    @dates.each (idx, date)=>
      dates = $.each $(date).data('dates'), (_, d) -> new Date(d)
      datepicker = new Datepicker
        trigger: $(date)
        immutable: true
        disablePastDates: false
      datepicker.model.setDates(dates)
    @bindEvents()

  bindEvents: ->
    @dates.on 'click', () ->
      false

