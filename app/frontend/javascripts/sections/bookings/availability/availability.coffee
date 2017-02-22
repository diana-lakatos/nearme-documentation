# Wrap queries on the availability data
module.exports = class Availability
  constructor: (@data) ->

  openFor: (date) ->
    @_value(date) != null

  availableFor: (date) ->
    @_value(date) or 0

  firstUnavailableDay: (date) ->
    prevDay = new Date(date)
    prevDay.setDate(date.getDate() - 1)
    !@_value(date) and @_value(prevDay)

  _value: (date) ->
    if month = @data["#{date.getFullYear()}-#{date.getMonth()+1}"]
      month[date.getDate()-1]
    else
      null
