# Availability Manager
#
# Handles determining availability for listing(s) on given day(s)
class @Bookings.AvailabilityManager

  # Keeps track of availability for listings.
  # Format:
  # { listingId : { 'dateid' : { availabile: 10, total: 12 } } }
  availability: {
  }

  constructor: (url) ->
    @url = url
    @pendingDates = []
    @pendingCallbacks = []

  availableFor: (listingId, date) ->
    value.available if value = @_value(listingId, date)

  totalFor: (listingId, date) ->
    value.total if value = @_value(listingId, date)

  isLoaded: (listingId, date) ->
    @_value(listingId, date)

  # Determine availability for a given date and listing
  #
  # listingId - Listing id to get availability for
  # date      - Date to fetch
  # callback  - Callback function to exectue
  get: (listingId, date, callback) ->
    dateId = DNM.util.Date.toId(date)

    if @isLoaded(listingId, date)
      @_executeCallback([listingId, date, callback])
    else
      @_scheduleFetch(listingId, date, callback)

  getAll: (date, callback) ->
    @_scheduleFetch(null, date, callback)

  # Make request to load pending availability info
  fetchPending: ->
    dates = $.map(@pendingDates, (date) -> DNM.util.Date.toId(date))
    callbacks = @pendingCallbacks

    # Reset the pending calls
    @pendingDates = []
    @pendingCallbacks = []

    # Execute the request to load the data
    $.ajax(@url, {
      dataType: 'json',
      data: { dates: dates },
      success: (data) =>
        # Go through each response and add date info
        _.each data, (listingData) =>
          @availability[listingData.id] = $.extend(@availability[listingData.id], listingData.availability)

        for callback in callbacks
          @_executeCallback(callback)
    })

  _value: (listingId, date) ->
    @availability[listingId]?[DNM.util.Date.toId(date)]

  # callback: [listingId, date, callback]
  _executeCallback: (callback) ->
    if callback[0]
      value = @_value(callback[0], callback[1])
      callback[2](value.available, value.total)
    else
      callback[2]()

  _scheduleFetch: (listingId, date, callback) ->
    @pendingDates.push(date)
    @pendingCallbacks.push([listingId, date, callback])
    clearTimeout(@pendingTimeout)
    @pendingTimeout = setTimeout(=>
      @fetchPending()
    , 500)





