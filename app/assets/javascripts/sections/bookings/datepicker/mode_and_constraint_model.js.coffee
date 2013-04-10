# Custom backing model for datepicker date selection
# Applies special semantics specific for booking selection:
#   * Multiple mode (select range, add/remove dates)
#   * Require minimum date selection (automatically constraint selection)
#
class @Bookings.Datepicker.ModeAndConstraintModel extends window.Datepicker.Model
  # Modes for the selection type. The different modes have different semantics when
  # a date is toggled.
  @MODE_RANGE = 'range'
  @MODE_PICK = 'pick'

  mode: @MODE_RANGE

  constructor: (listing) ->
    super

    @listing = listing
    @minDays = listing.minimumBookingDays or 1

    # "Range dates" are dates which haven't been explicitly added,
    # but are implicitly added through range selection or as a requirement
    # for minimum consecutive days.
    @rangeDates = {}

  setMode: (mode) ->
    @mode = mode

  toggleDate: (date) ->
    return unless @canSelectDate(date)

    switch @mode
      when Bookings.Datepicker.ModeAndConstraintModel.MODE_RANGE
        @setRangeTo(date)
        @extendRangeToMeetConstraint(date)
        @trigger 'rangeApplied'

      when Bookings.Datepicker.ModeAndConstraintModel.MODE_PICK
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
    while DNM.util.Date.toId(current) != DNM.util.Date.toId(date)
      if @canSelectDate(current)
        @addRangeDate(current)

      current = DNM.util.Date.next(current)

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
    @rangeDates[DNM.util.Date.toId(date)]

  # Flag whether a date was implicitly selected via a range selection
  # (and also constraint requirement)
  setRangeDate: (date) ->
    @rangeDates[DNM.util.Date.toId(date)] = true

  # Clear that a date was selected via range selection
  clearRangeDate: (date) ->
    @rangeDates[DNM.util.Date.toId(date)] = false

  canSelectDate: (date) ->
    @listing.availabilityFor(date) >= @listing.defaultQuantity

  # Starting at a given date, scan dates validate that it meets the consecutive bookings
  # constraint. If it doesn't, add next available dates until it does.
  extendRangeToMeetConstraint: (date) ->
    # Algorithm for extending to meet the min days constraint
    extender = (iteratorFunc) =>
      # We try to keep going until the target date meets the 
      # 'consecutive days' constraint.
      current = date
      until @meetsConstraint(date)
        # Grab the next date along
        current = iteratorFunc(current)

        # If we fall outside of the bookable dates for this listing,
        # break our loop.
        break unless @listing.dateWithinBounds(current)

        # If we can select this date, we add it.
        if @canSelectDate(current)
          @addRangeDate(current)

    # Iteration functions
    directionNext = (date) -> DNM.util.Date.next(date)
    directionPrev = (date) -> DNM.util.Date.previous(date)

    # Try to extend forward first, then work backwards.
    # We go backwards due to an edge case at the end of the bookable range,
    # where we need to add dates in the past to constraint the selection.
    extender(directionNext)
    extender(directionPrev)

  # Starting from a given date, scan the dates around it to ensure that the act of removing that
  # date hasn't invalidated the minimum date selection constraints. If it has, remove relevant
  # dates to restore selected dates to a state that reflects the minimum consecutive days constraint.
  reduceRangeToMeetConstraint: (date) ->
    # Remove previous date if doesn't meet constraint anymore
    previous = (date) -> DNM.util.Date.previous(date)
    next     = (date) -> DNM.util.Date.next(date)

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
    reducer = (iteratorFunc) =>
      current = iteratorFunc(date)
      while @listing.dateWithinBounds(current)
        if @canSelectDate(current)
          break if !@isSelected(current)
          break if @meetsConstraint(current)

          # Can no longer have this date selected
          @removeDate(current)

        # Iterate along to the next date
        current = iteratorFunc(current)

    # Check both future and past connected selected dates are now valid
    reducer(previous)
    reducer(next)

  # Returns whether or not there are minDays available days booked around
  # the specified date.
  meetsConstraint: (date) ->
    @consecutiveDays(date) >= @minDays

  # Return the consecutive days currently at the date, *or* the required minumum
  # consecutive days - whatever is less.
  consecutiveDays: (date) ->
    return 0 if !@isSelected(date)

    # Counter
    consecutive = 1

    # Iterator functions (backwards, forwards)
    directionPrev = (date) -> DNM.util.Date.previous(date)
    directionNext = (date) -> DNM.util.Date.next(date)

    # Our counting algorithm
    # We're trying to count the "consecutive days" total for the target date.
    # That is the number of connected days before or after the current date,
    # ignoring dates that aren't available for booking.
    counter = (iteratorFunc) =>
      current = iteratorFunc(date)
      while consecutive < @minDays
        break unless @listing.dateWithinBounds(current)

        if @isSelected(current)
          # We increment our counter if the date is selected
          consecutive++
        else
          # As soon as we encounter a date that is selectable, but isn't selected
          # we can break our counting loop, as it is no longer consecutive.
          break if @canSelectDate(current)
        
        # Advance to the next date to test against
        current = iteratorFunc(current)

    # Count backwards and forwards, using the same algorithm with a different
    # iteration function.
    counter(directionPrev)
    counter(directionNext)

    # Return our count of consecutive days
    consecutive

