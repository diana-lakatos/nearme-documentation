# Wrap queries on the availability data
module.exports = class Availability
  constructor: (@data) ->

  openFor: (date) ->
    @_value(date) != null

  availableFor: (date) ->
    @_value(date) or 0

  _value: (date) ->
    if month = @data["#{date.getFullYear()}-#{date.getMonth()+1}"]
      month[date.getDate()-1]
    else
      null
