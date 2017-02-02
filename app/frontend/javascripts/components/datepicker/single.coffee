DatepickerModel = require('./model')

# A special case of the datepicker backing model that only allows the selection of
# a single date.
module.exports = class DatepickerSingle extends DatepickerModel
  defaultOptions: $.extend({}, @prototype.defaultOptions, {
    # Allow deselecting the current active date
    allowDeselection: true
  })

  toggleDate: (date) ->
    # Check to see if we allow deselection
    return if !@options.allowDeselection and @isSelected(date)
    super(date)

  addDate: (date) ->
    if @_included.length > 0
      @removeDate(@_fromId(@_included[0]))
    super(date)


