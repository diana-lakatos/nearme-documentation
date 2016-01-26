module.exports = class Forms
  constructor: ->
    @bindEvents()
    @initialize()

  bindEvents: ->
    $('html').on 'datepickers.init.forms', (event, context = 'body')=>
      require.ensure './datepickers', (require)->
        DatepickersInitializer = require('./datepickers')
        new DatepickersInitializer(context)

    $('html').on 'selects.init.forms', (event, context = 'body')=>
      require.ensure './chosen', (require)->
        ChosenInitializer = require('./chosen')
        new ChosenInitializer(context)

  initialize: ()->
    if $('.datetimepicker').length > 0
      require.ensure './datepickers', (require)->
        DatepickersInitializer = require('./datepickers')
        new DatepickersInitializer()

    if $('select.chosen, select.select').length > 0
      require.ensure './chosen', (require)->
        ChosenInitializer = require('./chosen')
        new ChosenInitializer()

    if $('.selectpicker').length > 0
      require.ensure './selectpicker', (require)->
        SelectpickerInitializer = require('./selectpicker')
        new SelectpickerInitializer()
