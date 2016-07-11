# Wrap queries on the availability data
module.exports = class ScheduleAvailability
  constructor: (@data) ->

  openFor: (date) ->
    true

  availableFor: (date) ->
    1000