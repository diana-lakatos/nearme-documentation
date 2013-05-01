#= require_self
#= require ./datepicker/model
#= require ./datepicker/view
#
# Datepicker
#
# Supports multiple date selection
#
# datepicker = new Datepicker(
#   trigger: $('triger')
# )
#
class @Datepicker
  asEvented.apply @prototype

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

    @model = @options.model || new (@options.modelClass || Datepicker.Model)(@options)

    @view = @options.view || new (@options.viewClass || Datepicker.View)(@options)
    @view.setModel(@model)
    @view.appendTo($(@options.appendTo))

    @bindViewEvents()
    @bindEvents()

  bindEvents: ->
    $('body').on 'click', (event) =>
      if $(@options.trigger)[0] != event.target && $(@options.trigger).has(event.target).length == 0
        @view.hide()

    if @options.trigger
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

