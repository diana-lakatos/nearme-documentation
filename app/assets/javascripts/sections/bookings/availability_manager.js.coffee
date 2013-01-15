# Availability Manager
#
# Handles determining availability for listing(s) on given day(s)
class @Bookings.AvailabilityManager

  # Keeps track of availability for listings.
  # Format:
  # { listingId : { 'dateid' : { availabile: 10, total: 12 } } }
  availability: {
  }

  constructor: (url,fetchCompleteCallback) ->
    @url = url
    @pendingDates = []
    @pendingCallbacks = []
    @fetchCompleteCallback = fetchCompleteCallback || $.noop()

  availableFor: (listingId, date) ->
    value.available if value = @_value(listingId, date)

  totalFor: (listingId, date) ->
    value.total if value = @_value(listingId, date)

  isLoaded: (listingId, date_or_dates) ->
    if date_or_dates instanceof Array
      _.all date_or_dates, (date) => @isLoaded(listingId, date)
    else
      @_value(listingId, date_or_dates)

  # Determine availability for a given date and listing
  #
  # listingId - Listing id to get availability for
  # date      - Date to fetch
  # callback  - Callback function to exectue
  get: (listingId, date_or_dates, callback) ->
    if date_or_dates instanceof Array
      return @getDates(listingId, date_or_dates, callback)
    else
      date = date_or_dates

    dateId = DNM.util.Date.toId(date)

    if @isLoaded(listingId, date)
      @_executeCallback([listingId, date, callback]) if callback
    else
      @_scheduleFetch(listingId, date, callback)

  getDates: (listingId, dates, callback) ->
    pending = false
    for date in dates when !@isLoaded(listingId, date)
      pending = true
      @get(listingId, date)

    if pending
      @pendingCallbacks.push([null, null, callback]) if callback
    else
      callback() if callback

  getAll: (date, callback) ->
    @_scheduleFetch(null, date, callback)


  # Make request to load pending availability info
  fetchPending: ->
    dates = _.uniq $.map(@pendingDates, (date) -> DNM.util.Date.toId(date))
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

        @fetchCompleteCallback()
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
    @pendingCallbacks.push([listingId, date, callback]) if callback
    clearTimeout(@pendingTimeout)
    @pendingTimeout = setTimeout(=>
      @fetchPending()
    , 500)


  # Wrapper for availability for just a single listing
  class AvailabilityManager.Listing
    constructor: (@manager, @listingId) ->
    isLoaded: (date_or_dates) -> @manager.isLoaded(@listingId, date_or_dates)
    availableFor: (date) -> @manager.availableFor(@listingId, date)
    totalFor: (date) -> @manager.totalFor(@listingId, date)
    get: (date_or_dates, callback) -> @manager.get(@listingId, date_or_dates, callback)
    getDates: (dates, callback) -> @manager.getDates(@listingId, dates, callback)
