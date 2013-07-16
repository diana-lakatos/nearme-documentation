class @Dashboard.GuestsController

  constructor: (@container)->
    @dates = @container.find('.reservation-dates')
    @dates.each (idx, date)=>
      dates = $.each $(date).data('dates'), (_, d) -> new Date(d)
      datepicker = new Datepicker
        trigger: $(date)
        immutable: true
        disablePastDates: false
      datepicker.model.setDates(dates)
