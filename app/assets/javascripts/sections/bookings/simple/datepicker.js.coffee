class @Bookings.Simple.Datepicker

  constructor: (@container) ->
    # TODO: Implement custom multi dates selector with loading indicators, etc.
    @container.multiDatesPicker(
      onSelect: (d, inst) =>
        inst.inline = true
        setTimeout((-> inst.inline = false), 500)

        DNM.Event.notify this, 'datesChanged', [@getDates()]
    )
    $('#ui-datepicker-div').wrap('<div class="jquery-ui-theme" />')

  setDates: (dates) ->
    # FIXME: Doesn't remove dates?
    @container.multiDatesPicker('addDates', dates)

  getDates: ->
    @container.multiDatesPicker('getDates', 'object')





