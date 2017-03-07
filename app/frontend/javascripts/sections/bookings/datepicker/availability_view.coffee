DatepickerView = require('../../../components/datepicker/view')

# A view wrapper for the Datepicker to show a loading indicator while we load the date availability

module.exports = class AvailabilityView extends DatepickerView
  constructor: (@listing, options = {}) ->
    @isContinous = options.isContinous || false
    @firstUnavailable = null
    @activeDate = null

    @isEndDatepicker = options.endDatepicker
    super(options)

  show: ->
    # Refresh if listing quantity has changed since last display
    # We do this to update the display of available vs unavailable dates
    if @lastDefaultQuantity && @listing.defaultQuantity != @lastDefaultQuantity
      @refresh()

    @lastDefaultQuantity = @listing.defaultQuantity
    super

  # Extend the class generation method to add disabled state if the listing quantity selection
  # exceeds the availability for a given date.
  classForDate: (date, monthDate) ->
    klass = [super]
    qty = @listing.defaultQuantity
    qty = 1 if qty < 1

    if @model.isSelected(date)
      @activeDate = date

    if @listing.availabilityFor(date) < qty
      if @listing.isOvernightBooking() and @isEndDatepicker and @listing.firstUnavailableDay(date)
        klass.push 'datepicker-booking-end-only'
        @firstUnavailable = date if !@firstUnavailable and @activeDate and date >= @activeDate
      else
        klass.push 'disabled'
        klass.push 'closed' unless @listing.openFor(date)


    if @isEndDatepicker and date < @activeDate
      klass.push 'before-start-date'

    if @listing.isOvernightBooking() and @firstUnavailable and date > @firstUnavailable
      klass.push 'not-available'

    # Our custom model keeps track of whether dates were added via the range
    # selection.
    if @model.isRangeDate and @model.isRangeDate(date)
      if @isContinous
        klass.push 'implicit'
      else
        klass.push 'active'

    klass.join ' '

