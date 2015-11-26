class @DNM.Forms
  constructor: ->
    @root = $('html')
    @bindEvents()
    @initialize()

  bindEvents: ->
    @root.on 'loaded.dialog', =>
      @initialize('.dialog')

    @root.on 'datepickers.init.forms', (event, context = 'body')=>
      @datepickers(context)

    @root.on 'hints.init.forms', (event, context = 'body')=>
      @hints(context)

    @root.on 'tooltips.init.forms', (event, context = 'body')=>
      @tooltips(context)

    @root.on 'selects.init.forms', (event, context = 'body')=>
      @selects(context)

  hints: (context = 'body')->
    $(context).find('.form-group .help-block.hint').each ()->
      content = $(this).html()
      toggler = $('<button type="button" class="hint-toggler" data-toggle="tooltip" data-placement="right" title="' + content + '">Toggle hint</button>')
      $(this).closest('.form-group').find('label.control-label').append(toggler)

  tooltips: (context = 'body')->
    $(context).find('[data-toggle="tooltip"]').tooltip()

  selects: (context = 'body')->
    $(context).find('.form-group select').selectize
      plugins: ['remove_button']
      onInitialize: ->
        s = @;
        @revertSettings.$children.each ()->
          $.extend(s.options[@value], $(@).data())


  datepickers: (context = 'body')->
    $(context).find('.datetimepicker').datetimepicker({
      allowInputToggle: true,
      icons: {
        time: 'fa fa-clock-o',
        date: 'fa fa-calendar-o',
        up: 'fa fa-chevron-up',
        down: 'fa fa-chevron-down',
        previous: 'fa fa-chevron-left',
        next: 'fa fa-chevron-right',
        today: 'fa fa-crosshairs',
        clear: 'fa fa-trash-o',
        close: 'fa fa-times'
      }
    })

  initialize: (context = 'body')->
    @hints(context)
    @tooltips(context)
    @selects(context)
    @datepickers(context)

new DNM.Forms()
