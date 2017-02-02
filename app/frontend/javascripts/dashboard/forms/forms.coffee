module.exports = class Forms
  constructor: ->
    @root = $('html')
    @bindEvents()
    @initialize()

  bindEvents: ->
    @root.on 'loaded:dialog.nearme', =>
      @initialize('.dialog')

    @root.on 'datepickers.init.forms', (event, context = 'body') ->
      require.ensure './datepickers', (require) ->
        datepickers = require('./datepickers')
        datepickers(context)

    @root.on 'timepickers.init.forms', (event, context = 'body') ->
      require.ensure './timepickers', (require) ->
        timepickers = require('./timepickers')
        timepickers(context)

    @root.on 'hints.init.forms', (event, context = 'body') ->
      require.ensure './hints', (require) ->
        hints = require('./hints')
        hints(context)

    @root.on 'tooltips.init.forms', (event, context = 'body') ->
      require.ensure './tooltips', (require) ->
        tooltips = require('./tooltips')
        tooltips(context)

    @root.on 'selects.init.forms', (event, context = 'body') ->
      require.ensure './selects', (require) ->
        selects = require('./selects')
        selects(context)

  hints: (context = 'body') ->
    els = $(context).find('.form-group .help-block.hint')
    return unless els.length > 0

    require.ensure './hints', (require) ->
      hints = require('./hints')
      hints(context)

  tooltips: (context = 'body') ->
    els = $(context).find('[data-toggle="tooltip"]')
    return unless els.length > 0

    require.ensure './tooltips', (require) ->
      tooltips = require('./tooltips')
      tooltips(context)

  selects: (context = 'body') ->
    els = $(context).find('.form-group select')
    return unless els.length > 0

    require.ensure './selects', (require) ->
      selects = require('./selects')
      selects(context)

  datepickers: (context = 'body') ->
    els = $(context).find('.datetimepicker')
    return unless els.length > 0

    require.ensure './datepickers', (require) ->
      datepickers = require('./datepickers')
      datepickers(context)

  timepickers: (context = 'body') ->
    els = $(context).find('.time_picker')
    return unless els.length > 0

    require.ensure './timepickers', (require) ->
      timepickers = require('./timepickers')
      timepickers(context)

  ranges: (context = 'body') ->
    els = $(context).find('.custom_range')
    return unless els.length > 0

    require.ensure './ranges', (require) ->
      ranges = require('./ranges')
      ranges(els)

  initialize: (context = 'body') ->
    @hints(context)
    @tooltips(context)
    @datepickers(context)
    @selects(context)
    @timepickers(context)
    @ranges(context)
