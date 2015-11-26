class @DNM.InstanceAdmin.Forms
  constructor: ->

    @root = $('html')
    @bindEvents()
    @datepickers()
    @selects()

  bindEvents: ->
    @root.on 'datepickers.init.forms', (event, context = 'body')=>
      @datepickers(context)

    @root.on 'selects.init.forms', (event, context = 'body')=>
      @selects(context)


  selects: (context = 'body')->
    $(context).find('select.select').chosen({ width: '100%' })

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


new DNM.InstanceAdmin.Forms()


