Availability = require('./availability')
dateUtil = require('../../../lib/utils/date')

# Extends the simple daily availability wrapper to provide quantity
# down to the hourly level for specific days. Provides the same semantics
# if called without a provided minute, or provides hourly semantics if called
# with a minute as an additional parameter.
# Encapsulates deferred loading of the hourly availability.
module.exports = class HourlyAvailability extends Availability
  constructor: (@data, @schedule, @scheduleUrl) ->
    super(@data)

  openFor: (date, minute) ->
    @_value(date, minute) != null

  availableFor: (date, minute) ->
    @_value(date, minute) or 0

  hasSchedule: (date) ->
    !!@_schedule(date)

  # Fire off a remote request (if required) to load the hourly availability
  # schedule for a given date. Execute the provided callback when ready
  # to use.
  loadSchedule: (date, callback) ->
    if !@hasSchedule(date)
      dateId = dateUtil.toId(date)
      $.get(@scheduleUrl + "?date=#{dateId}").success (data) =>
        @schedule[dateId] = data
        callback(date)
    else
      callback(date)

  _schedule: (date) ->
    @schedule[dateUtil.toId(date)]

  _value: (date, minute) ->
    if minute
      if hours = @_schedule(date)
        hours[minute.toString()] or null
      else
        super(date)
    else
      super(date)

