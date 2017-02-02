# Controller for handling each reservation in my bookings page
#
# The controller is initialized with the reservation DOM container.
module.exports = class ReservationUserReservationController

  constructor: (@container, @options = {}) ->
    @dates = @container.find('a[data-dates]')
    @times = @container.find('a[data-reservation-hours]')
    @datepicker()
    @tooltip()
    @bindEvents()

  tooltip: ->
    @times.each (idx, el) ->
      text = $(el).data('reservation-hours')
      $(el).tooltip(title: text, html: true)

  datepicker: ->
    @dates.each (idx, date) ->
      dates = $.each $(date).data('dates'), (_, d) -> new Date(d)
      datepicker = new Datepicker
        trigger: $(date)
        immutable: true
        disablePastDates: false
      datepicker.model.setDates(dates)

  bindEvents: ->
    @dates.on 'click', ->
      false
    @times.on 'click', ->
      false

