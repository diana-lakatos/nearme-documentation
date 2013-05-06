# A special view to handle rendering the month highlighting the days between
# the 'start datepicker' and the 'end datepicker'
class Search.SearchRangeDatepickerView extends window.Datepicker.View
  constructor: (@startDatepicker, options = {}) ->
    super(options)

  show: ->
    super
    # Refresh every time it's opened. We do this because if the start-date has changed, the
    # dates in between start-end would not have refreshed.
    @refresh()

  # The default 'update date' is fired when a date is selected. However, since we have custom
  # rendering for other dates in the month, we also need to update those days. So we just
  # do a full refresh of the current month being displayed.
  updateDate: (date) ->
    @refresh()

  classForDate: (date, month) ->
    klass = [super(date, month)]

    startDate = @startDatepicker.getDates()[0]
    endDate = @model.getDates()[0] or startDate

    if startDate
      # Depending on where the current date being rendered fits in our current
      # range, we assign relevant css classes for display.
      if endDate.getTime() == date.getTime()
        klass.push 'active'
      else if date.getTime() >= startDate.getTime() and date.getTime() <= endDate.getTime()
        klass.push 'active implicit'
      else if date.getTime() < startDate.getTime()
        klass.push 'disabled closed'

    klass.join ' '

