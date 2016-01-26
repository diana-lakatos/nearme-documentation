asEvented = require('asEvented')
DatepickerModel = require('./datepicker/model')
DatepickerView = require('./datepicker/view')

# Datepicker
#
# Supports multiple date selection
#
# datepicker = new Datepicker(
#   trigger: $('triger')
# )
#
module.exports = class Datepicker
  asEvented.call @prototype

  defaultOptions: {
    containerClass: 'dnm-datepicker',
    appendTo: 'body',

    # Inject the view object managed by this Datepicker
    view: null,
    viewClass: null,

    model: null,
    modelClass: null,
  }

  constructor: (@options = {}) ->
    @options = $.extend({}, @defaultOptions, @options)

    @model = @options.model || new (@options.modelClass || DatepickerModel)(@options)

    @view = @options.view || new (@options.viewClass || DatepickerView)(@options)
    @view.setModel(@model)
    @view.appendTo($(@options.appendTo))

    @bindViewEvents()
    @bindEvents()

  bindEvents: ->
    if @options.trigger
      @view.closeIfClickedOutside(@options.trigger) if @options.trigger

      $(@options.trigger).on 'click', (event) =>
        @view.toggle()

  bindViewEvents: ->
    @view.bind 'prevClicked', =>
      @model.advanceMonth(-1)

    @view.bind 'nextClicked', =>
      @model.advanceMonth(1)

    @view.bind 'dateClicked', (date) =>
      @model.toggleDate(date)
      @trigger 'datesChanged', @model.getDates()

    @model.bind 'dateAdded', (date) =>
      @view.dateAdded(date)

    @model.bind 'dateRemoved', (date) =>
      @view.dateRemoved(date)

    @model.bind 'monthChanged', (newMonth) =>
      @view.renderMonth(newMonth)

  show: -> @view.show()
  hide: -> @view.hide()
  toggle: -> @view.toggle()
  getDates: -> @model.getDates()
  setDates: (dates) -> @model.setDates(dates)
  removeDate: (date) -> @model.removeDate(date)
  addDate: (date) -> @model.addDate(date)

  getView: ->
    @view

  getModel: ->
    @model

