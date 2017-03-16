DatepickerModel = require('../../../components/datepicker/model')
dateUtil = require('../../../lib/utils/date')

# Custom backing model for datepicker date selection
# Applies special semantics specific for booking selection:
#   * Multiple mode (select range, add/remove dates)
#   * Require minimum date selection (automatically constraint selection)
#
module.exports = class ModeAndConstraintModel extends DatepickerModel
  # Modes for the selection type. The different modes have different semantics when
  # a date is toggled.
  @MODE_RANGE = 'range'
  @MODE_PICK = 'pick'

  mode: @MODE_RANGE

  constructor: (listing) ->
    super

    @listing = listing

    # "Range dates" are dates which haven't been explicitly added,
    # but are implicitly added through range selection or as a requirement
    # for minimum consecutive days. We keep track of these so we can display
    # them differently on the view.
    @rangeDates = {}

  setMode: (mode) ->
    @mode = mode

  minDays: ->
    @listing.minimumBookingDays() or 1

  toggleDate: (date) ->
    return unless @canSelectDate(date)

    startDate = @getDates().slice(0, 1)[0]
    return if @listing.isOvernightBooking() && !@areConsecutiveDays(startDate, date)

    switch @mode
      when ModeAndConstraintModel.MODE_RANGE

        # Return if there is no start date, or if date selected
        # is before the start date (can't select backwards)
        if !startDate or startDate.getTime() > date.getTime()
          return

        # Don't allow making a range selection that doesn't meet
        # the consecutive days constraint
        if @minDays() > 1 and @consecutiveDaysBetween(startDate, date) < @minDays()
          return

        # Reset the range
        @setDates([startDate])

        # Extend the range
        @setRangeTo(date)
        @extendRangeToMeetConstraint(date)
        @trigger 'rangeApplied'

      when ModeAndConstraintModel.MODE_PICK
        if @isSelected(date)
          @removeDate(date)
          @reduceRangeToMeetConstraint(date)
        else
          @addDate(date)
          @extendRangeToMeetConstraint(date)

  # Set the date range to the specified date, from the first date.
  setRangeTo: (date) ->
    return unless @listing.dateWithinBounds(date)

    startDate = @getDates()[0] || date

    # If the to-date is before the start-date, then we set both ends to
    # the same date (i.e. no range)
    startDate = date if startDate.getTime() > date.getTime()

    current = startDate
    while dateUtil.toId(current) != dateUtil.toId(date)
      if @canSelectDate(current)
        @addRangeDate(current)

      current = dateUtil.next(current)

    @addDate(date) if @canSelectDate(date)

  # Wrap remove date to clear the previous 'range date' state, a special
  # state for this specific use case.
  removeDate: (date) ->
    @clearRangeDate(date)
    super

  # Wrapper for addDate that sets the date as an range-added date.
  addRangeDate: (date) ->
    @setRangeDate(date)
    @addDate(date)

  # Test whether a date was implicitly added as a 'range date'
  isRangeDate: (date) ->
    @rangeDates[dateUtil.toId(date)]

  # Flag whether a date was implicitly selected via a range selection
  # (and also constraint requirement)
  setRangeDate: (date) ->
    @rangeDates[dateUtil.toId(date)] = true

  # Clear that a date was selected via range selection
  clearRangeDate: (date) ->
    @rangeDates[dateUtil.toId(date)] = false

  # Returns whether or not a date is 'selectable' based on the listing availability
  canSelectDate: (date) ->
    @listing.canBookDate(date)

  # Ensure all included dates meet the consecutive days constraint, and
  # extend them if they don't.
  ensureDatesMeetConstraint: ->
    for date in @getDates()
      @extendRangeToMeetConstraint(date)

  # Returns whether or not there are minDays available days booked around
  # the specified date.
  meetsConstraint: (date) ->
    @consecutiveDays(date) >= @minDays()

  # Starting at a given date, scan dates validate that it meets the consecutive bookings
  # constraint. If it doesn't, add next available dates until it does.
  extendRangeToMeetConstraint: (date) ->
    # Algorithm for extending to meet the min days constraint
    bookingExtensionAlgorithm = (dateIterator) =>
      # We try to keep going until the target date meets the
      # 'consecutive days' constraint.
      until @meetsConstraint(date)
        currentDate = dateIterator()

        # If we fall outside of the bookable dates for this listing,
        # break our loop.
        break unless @listing.dateWithinBounds(currentDate)

        # If we can select this date, we add it.
        if @canSelectDate(currentDate)
          @addRangeDate(currentDate)
        else if @listing.isOvernightBooking()
          break

    # Try to extend forward first, then work backwards.
    # We go backwards due to an edge case at the end of the bookable range,
    # where we need to add dates in the past to constraint the selection.
    bookingExtensionAlgorithm(dateUtil.nextDateIterator(date))
    bookingExtensionAlgorithm(dateUtil.previousDateIterator(date)) unless @listing.isOvernightBooking()

  # Starting from a given date, scan the dates around it to ensure that the act of removing that
  # date hasn't invalidated the minimum date selection constraints. If it has, remove relevant
  # dates to restore selected dates to a state that reflects the minimum consecutive days constraint.
  reduceRangeToMeetConstraint: (date) ->
    # Iterates with an advancer through the selected dates adjacent to the starting date,
    # and validates that that date meets the restrictions.
    #
    # Three cases:
    #   * Date is selected. We validate that it still meets the constraints
    #     * If it does, we are done.
    #     * If it doesn't, we unselect the date and try the next one
    #   * Date is not selectable
    #     * We move to the next date - as it being unselectable isn't included
    #       in 'consecutive' semantics.
    #   * Date is not selected
    #     * We are done - as we assume other dates already meet requirements.
    bookingRemovalAlgorithm = (dateIterator) =>
      while currentDate = dateIterator()
        break unless @listing.dateWithinBounds(currentDate)
        if @canSelectDate(currentDate)
          break if !@isSelected(currentDate)
          break if @meetsConstraint(currentDate)

          # Can no longer have this date selected
          @removeDate(currentDate)

    # Check both future and past connected selected dates are now valid
    bookingRemovalAlgorithm(dateUtil.previousDateIterator(date))
    bookingRemovalAlgorithm(dateUtil.nextDateIterator(date))

  # Return the consecutive days currently booked at the date, *or*
  # the required minumum consecutive days - whatever is less.
  consecutiveDays: (date) ->
    return 0 if !@isSelected(date)

    consecutiveDaysCount = 1
    countingAlgorithm = (dateIterator) =>
      # We're trying to count the "consecutive days" total for the target date.
      # That is the number of connected days before or after the current date,
      # ignoring dates that aren't available for booking.
      while consecutiveDaysCount < @minDays()
        currentDate = dateIterator()
        break unless @listing.dateWithinBounds(currentDate)

        if @isSelected(currentDate)
          # We increment our counter if the date is selected
          consecutiveDaysCount++
        else
          # As soon as we encounter a date that is selectable, but isn't selected
          # we can break our counting loop, as it is no longer consecutive.
          break if @canSelectDate(currentDate)

    # Count backwards and forwards, using the same algorithm with a different
    # iteration function.
    countingAlgorithm(dateUtil.previousDateIterator(date))
    countingAlgorithm(dateUtil.nextDateIterator(date))
    consecutiveDaysCount

  # Return a count of the available consecutive days between two dates, or the
  # minimum required consecutive days - whichever is less.
  consecutiveDaysBetween: (startDate, endDate) ->
    return 0 if endDate.getTime() < startDate.getTime()
    count = 0
    current = startDate
    while count < @minDays() and current.getTime() <= endDate.getTime()
      count += 1 if @canSelectDate(current)
      current = dateUtil.next(current)
    count

  # Checks whether range doesn't contain unavailable days
  areConsecutiveDays: (startDate, endDate) ->
    return false if endDate.getTime() < startDate.getTime()
    current = startDate
    while current.getTime() <= endDate.getTime()
      return false unless @canSelectDate(current)
      current = dateUtil.next(current)
    true
