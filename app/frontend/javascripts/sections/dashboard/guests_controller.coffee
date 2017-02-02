Datepicker = require('../../components/datepicker')

module.exports = class DashboardGuestsController

  constructor: (@container) ->
    @dates = @container.find('a[data-dates]')
    @dates.each (idx, date) ->
      dates = $.each $(date).data('dates'), (_, d) -> new Date(d)
      datepicker = new Datepicker
        trigger: $(date)
        immutable: true
        disablePastDates: false
      datepicker.model.setDates(dates)
    @bindEvents()

  bindEvents: ->
    @dates.on 'click', ->
      false
