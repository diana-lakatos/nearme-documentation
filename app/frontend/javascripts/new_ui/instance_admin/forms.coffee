require('chosen/chosen.jquery')

module.exports = class InstanceAdminForms
  constructor: ->

    @datepickers = require('../forms/datepickers')
    @timepickers = require('../forms/timepickers')

    @root = $('html')
    @bindEvents()
    @datepickers()
    @timepickers()
    @selects()

  bindEvents: ->
    @root.on 'datepickers.init.forms', (event, context = 'body')=>
      @datepickers(context)

    @root.on 'timepickers.init.forms', (event, context = 'body')=>
      @timepickers(context)

    @root.on 'selects.init.forms', (event, context = 'body')=>
      @selects(context)


  selects: (context = 'body')->
    $(context).find('select.select').chosen({ width: '100%' })
