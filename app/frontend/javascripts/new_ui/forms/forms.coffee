module.exports = class Forms
  constructor: ->
    @root = $('html')
    @bindEvents()
    @initialize()

  bindEvents: ->
    @root.on 'loaded.dialog', =>
      require.ensure ['./datepickers', './hints','./tooltips', './selects', './ckeditor'], (require)=>
        datepickers = require('./datepickers')
        datepickers('.dialog')

        hints = require('./hints')
        hints('.dialog')

        tooltips = require('./tooltips')
        tooltips('.dialog')

        selects = require('./selects')
        selects('.dialog')

        ckeditor = require('./ckeditor')
        ckeditor('.dialog')

    @root.on 'datepickers.init.forms', (event, context = 'body')=>
      require.ensure './datepickers', (require)->
        datepickers = require('./datepickers')
        datepickers(context)

    @root.on 'hints.init.forms', (event, context = 'body')=>
      require.ensure './hints', (require)->
        hints = require('./hints')
        hints(context)

    @root.on 'tooltips.init.forms', (event, context = 'body')=>
      require.ensure './tooltips', (require)->
        tooltips = require('./tooltips')
        tooltips(context)

    @root.on 'selects.init.forms', (event, context = 'body')=>
      require.ensure './selects', (require)->
        selects = require('./selects')
        selects(context)

    @root.on 'ckeditor.init.forms', (event, context = 'body')=>
      require.ensure './ckeditor', (require)->
        ckeditor = require('./ckeditor')
        ckeditor(context)

  hints: (context = 'body')->
    els = $(context).find('.form-group .help-block.hint');
    return unless els.length > 0

    require.ensure './hints', (require)->
      hints = require('./hints')
      hints(context)

  tooltips: (context = 'body')->
    els = $(context).find('[data-toggle="tooltip"]');
    return unless els.length > 0

    require.ensure './tooltips', (require)->
      tooltips = require('./tooltips')
      tooltips(context)

  selects: (context = 'body')->
    els = $(context).find('.form-group select');
    return unless els.length > 0

    require.ensure './selects', (require)->
      selects = require('./selects')
      selects(context)

  datepickers: (context = 'body')->
    els = $(context).find('.datetimepicker');
    return unless els.length > 0

    require.ensure './datepickers', (require)->
      datepickers = require('./datepickers')
      datepickers(context)

  ckeditor: (context = 'body')->
    els = $(context).find('.ckeditor');
    return unless els.length > 0

    require.ensure './ckeditor', (require)->
      ckeditor = require('./ckeditor')
      ckeditor(context)

  initialize: (context = 'body')->
    @hints(context)
    @tooltips(context)
    @datepickers(context)
    @selects(context)
    @ckeditor(context)
