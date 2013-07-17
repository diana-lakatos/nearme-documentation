class Search.RangeDatePickerFilter

  constructor: (@start, @end, @updateCallback)->
    @initDatepickers()
    @setInitialDates()
    @addEventHandlers()

  updateDateFields: ->
    formatDate = (date) ->
      if date
        "#{DNM.util.Date.monthName(date, 3)} #{date.getDate()}"
      else
        ""

    startDate = formatDate @startDatepicker.getDates()[0]
    endDate   = formatDate @endDatepicker.getDates()[0]

    @startInput().val(startDate)
    @endInput().val(endDate)
    @updateCallback([startDate, endDate])

  startDatepickerChanged: ->
    @startDatepicker.hide()

    if startDate = @startDatepicker.getDates()[0]
      endDate = @endDatepicker.getDates()[0]
      if !endDate or endDate.getTime() < startDate.getTime()
        @endDatepicker.setDates([startDate])

      @endDatepicker.show()
    else
      # Deselection
      @endDatepicker.setDates([])

    @updateDateFields()

  endInput: ()->
    @end.find('input')

  startInput: ()->
    @start.find('input')

  initDatepickers: ()->
    @startDatepicker = new window.Datepicker(
      trigger: @start,
      positionTarget: @startInput(),
      text: '<div class="datepicker-text-fadein">Select a start date</div>',

    # Limit to a single date selected at a time
      model: new window.Datepicker.Model.Single(
        allowDeselection: true
      )
    )

    @endDatepicker = new window.Datepicker(
      trigger: @end,
      view: new Search.SearchRangeDatepickerView(@startDatepicker,
        positionTarget: @endInput(),
        text: '<div class="datepicker-text-fadein">Select an end date</div>'
      ),

    # Limit to a single date selected at a time
      model: new window.Datepicker.Model.Single(
        allowDeselection: false
      )
    )

  setInitialDates: ()->
    return unless @startDatepicker and @endDatepicker
    date = new Date()
    if @startInput().data('value')
      date.setTime(Date.parse(@startInput().data('value')))
      @startDatepicker.addDate(date)
    if @endInput().data('value')
      date.setTime(Date.parse(@endInput().data('value')))
      @endDatepicker.addDate(date)

  addEventHandlers: ()->
    @startDatepicker.on 'datesChanged', =>
      @startDatepickerChanged()

    @endDatepicker.on 'datesChanged', =>
      @updateDateFields()

    @end.on 'click', (e) =>
      if @startDatepicker.getDates()[0]
        @startDatepicker.hide()
      else
        @startDatepicker.show()
        @endDatepicker.hide()

      e.stopPropagation()
      false

