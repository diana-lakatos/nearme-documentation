class @Dashboard.GuestsController

  constructor: (@container)->
    @dates = @container.find('.reservation-dates')
    @dates.each (idx, date)=>
      started = new Date($(date).data('start'))
      finished = new Date($(date).data('end'))
      datepicker = new Datepicker
        trigger: $(date)
      datepicker.model.setDates(@getDatesBetween(started,finished))


  getDatesBetween: (dateA, dateB)->
    days = [new Date(dateA)]
    while dateA < dateB
      dateA.setDate(dateA.getDate() + 1)
      days.push new Date(dateA)
    days