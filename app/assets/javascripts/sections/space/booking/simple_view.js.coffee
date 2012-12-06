# Contains all the view logic of the 'simple' view of the booking system
class @Space.Booking.SimpleView

  constructor: ->

  # Setup the datepicker for the simple booking UI
  _setupMultiDatesPicker: ->
    calendarContainer = $(".quick-book .calendar input")
    return unless calendarContainer.length > 0
    tomorrow = new Date(new Date().getTime() + 24 * 60 * 60 * 1000)
    calendarContainer.multiDatesPicker(
      addDates: [tomorrow]
      onSelect: (d, inst) =>
        inst.inline = true
        setTimeout((-> inst.inline = false), 500)

        listing = @findListing $(inst.input).closest('.listing').attr('data-listing-id')
        dates = inst.input.multiDatesPicker('getDates', 'object')
        listing.setDates(dates)
    )

    $('#ui-datepicker-div').wrap('<div class="jquery-ui-theme" />')



