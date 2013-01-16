# Datepicker
#
# Supports multiple date selection
#
# datepicker = new Datepicker(
#   trigger: $('triger')
# )
class @Datepicker
  defaultOptions: {
    containerClass: 'dnm-datepicker',
    appendTo: 'body',

    # The initial month of the view, specified as a Date object
    initialMonth: null,

    # The 'today' for the view, specified as a Date object
    today: null,

    # The initial 'selected dates' for the calendar
    selectedDates: null,

    # Inject the view object managed by this Datepicker
    view: null,
    viewClass: null,

    # Events
    # Triggered when the set of selected dates is changed
    onDatesChanged: null
  }

  constructor: (@options = {}) ->
    @options = $.extend({}, @defaultOptions, @options)

    @model = new Datepicker.Model(
      selectedDates: @options.selectedDates || [],
      currentMonth:  @options.initialMonth || new Date(),
      today:         @options.today || new Date()
    )

    @view = @options.view || new (@options.viewClass || Datepicker.View)(@options)
    @view.setModel(@model)
    @view.appendTo($(@options.appendTo))

    if @options.onDatesChanged
      @model.on 'dateRemoved dateAdded', => @options.onDatesChanged(@model.getDates())

    @bindViewEvents()
    @bindEvents()

  bindEvents: ->
    $('body').on 'click', (event) =>
      @view.hide()

    if @options.trigger
      $(@options.trigger).on 'click', (event) =>
        event.stopPropagation()
        @view.toggle()

  bindViewEvents: ->
    @view.bind 'prevClicked', =>
      @model.advanceMonth(-1)

    @view.bind 'nextClicked', =>
      @model.advanceMonth(1)

    @view.bind 'dateClicked', (date) =>
      @model.toggleDate(date)

  show: -> @view.show()
  hide: -> @view.hide()
  getDates: -> @model.getDates()
  setDates: (dates) -> @model.setDates(dates)
  removeDate: (date) -> @model.removeDate(date)
  addDate: (date) -> @model.addDate(date)

  class Datepicker.Model
    asEvented.call(Model.prototype)

    constructor: (options) ->
      @currentMonth = options.currentMonth
      @_included = []
      @today = options.today

      @setDates(options.selectedDates) if options.selectedDates

    advanceMonth: (incr = 1) ->
      @currentMonth = new Date(@currentMonth.getFullYear(), @currentMonth.getMonth()+incr, 1, 0, 0, 0, 0)
      @trigger('monthChanged', @currentMonth)

    isSelected: (date) ->
      @_included.indexOf(@_asId(date)) != -1

    getDates: ->
      _.map @_included, (dateId) => @_fromId(dateId)

    toggleDate: (date) ->
      if @isSelected(date)
        @removeDate(date)
      else
        @addDate(date)

    removeDate: (date) ->
      dateId = @_asId(date)
      return unless @isSelected(dateId)

      @_included.splice @_included.indexOf(dateId), 1
      @trigger('dateRemoved', date)

    addDate: (date) ->
      dateId = @_asId(date)
      return if @isSelected(dateId)

      @_included.push dateId
      @trigger('dateAdded', date)

    setDates: (dates) ->
      newDates = []
      newDates.push(@_asId(date)) for date in dates

      added = _.difference(newDates, @_included)
      removed = _.difference(@_included, newDates)

      @removeDate(@_fromId(date)) for date in removed
      @addDate(@_fromId(date)) for date in added

    _asId: (date) ->
      DNM.util.Date.toId(date)

    _fromId: (dateId) ->
      DNM.util.Date.idToDate(dateId)

  # View renderer for the calendar
  class Datepicker.View
    asEvented.call(View.prototype)

    viewTemplate: '''
      <div class="datepicker-prev ico-arrow-left"></div>
      <div class="datepicker-next ico-arrow-right"></div>

      <div class="datepicker-header">
        <div class="datepicker-month"></div>
        <div class="datepicker-year"></div>
      </div>

      <div class="datepicker-week-header">
        <div class="datepicker-week-heading">S</div>
        <div class="datepicker-week-heading">M</div>
        <div class="datepicker-week-heading">T</div>
        <div class="datepicker-week-heading">W</div>
        <div class="datepicker-week-heading">T</div>
        <div class="datepicker-week-heading">F</div>
        <div class="datepicker-week-heading">S</div>
      </div>

      <div class="datepicker-days-wrapper">
        <div class="datepicker-days"></div>
        <div class="datepicker-loading"><i></i></div>
      </div>
    '''

    dayTemplate: '''
      <div class="datepicker-day datepicker-day-{{year}}-{{month}}-{{day}} datepicker-day-dow-{{dow}} {{klass}}" data-year="{{year}}" data-month="{{month}}" data-day="{{day}}">{{day}}</div>
    '''

    defaultOptions: {
      # Target for positioning of the popover view
      positionTarget: null,

      # Padding in px as spacing around the positioning popover
      positionPadding: 5,

      # Whether to disable past dates
      disablePastDates: true
    }

    constructor: (@options = {}) ->
      @options = $.extend({}, @defaultOptions, @options)
      @positionTarget = @options.positionTarget || @options.trigger
      @container = $('<div />').hide()
      @container.addClass(@options.containerClass || 'dnm-datepicker')
      @container.html(@viewTemplate)
      @monthHeader = @container.find('.datepicker-month')
      @yearHeader  = @container.find('.datepicker-year')
      @prev = @container.find('.datepicker-prev')
      @next = @container.find('.datepicker-next')
      @weekHeader = @container.find('.datepicker-week-header')
      @daysContainer = @container.find('.datepicker-days')
      @loading = @container.find('.datepicker-loading').hide()

      @bindEvents()

    # Set the model for the view
    setModel: (@model) ->
      @bindModel()

    # Render the the datepicker view by appending it to a container
    appendTo: (selector) ->
      $(selector).append(@container)

    toggle: ->
      if @container.is(':visible')
        @hide()
      else
        @show()

    show: ->
      # Reset rendering position
      @renderPosition = null

      # Refresh the view on the first display
      if !@hasRendered
        @refresh()

      @container.show()
      @reposition()

    hide: ->
      @container.hide()

    reposition: ->
      return unless @positionTarget

      # Width/height of the datepicker container
      width = @container.width()
      height = @container.height()

      # Offset of the position target reletave to the page
      tOffset = $(@positionTarget).offset()

      # Width/height of the position target
      tWidth = $(@positionTarget).width()
      tHeight = $(@positionTarget).height()

      # Window height and scroll position
      wHeight = $(window).height()
      sTop    = $(window).scrollTop()

      # Calculate available viewport height above/below the target
      heightAbove = tOffset.top - sTop
      heightBelow = wHeight + sTop - tOffset.top

      # Determine whether to place the datepicker above or below the target element.
      # If there is enough window height above element to render the container, then we put it
      # above. If there is not enough (i.e. it would be partially hidden if rendered above), then
      # we render it below the target.
      if @renderPosition != 'below' && (@renderPosition == 'above' || heightAbove < height)
        top = tOffset.top + tHeight + @options.positionPadding
        @renderPosition = 'above'
      else
        # Render above element
        top = tOffset.top - height - @options.positionPadding
        @renderPosition = 'below'

      # Left position is based off the container width and the position target width/position
      left = tOffset.left + parseInt(tWidth/2, 10) - parseInt(width/2, 10)

      # Update the position of the datepicker container
      @container.css(
        'top': "#{top}px",
        'left': "#{left}px"
      )

    # Listen to changes on the model to re-render the view
    bindModel: ->
      @model.bind 'dateAdded', (date) =>
        @dateElement(date).addClass('active')

      @model.bind 'dateRemoved', (date) =>
        @dateElement(date).removeClass('active')

      @model.bind 'monthChanged', (newMonth) =>
        @renderMonth(newMonth)

    # Setup and bind fields within the container
    bindEvents: ->
      # Clicking on a date element
      @daysContainer.on 'click', '.datepicker-day', (event) =>
        dayEl = $(event.target).closest('.datepicker-day')
        return if dayEl.is('.disabled')

        y = parseInt(dayEl.attr('data-year'), 10)
        m = parseInt(dayEl.attr('data-month'), 10)
        d = parseInt(dayEl.attr('data-day'), 10)
        @trigger 'dateClicked', new Date(y, m, d, 0, 0, 0, 0)

      # Clicking previous/next
      @prev.on 'click', (event) => @trigger('prevClicked')
      @next.on 'click', (event) => @trigger('nextClicked')

      @container.on 'click', (event) => event.stopPropagation()

    # Render all state again
    refresh: ->
      @renderMonth(@model.currentMonth)
      @hasRendered = true

    # Set loading state
    setLoading: (state) ->
      if state
        @loading.show()
      else
        @loading.fadeOut('fast')

    # Get the day element on the current calendar view, if any.
    dateElement: (date) ->
      @daysContainer.find(".datepicker-day-#{date.getFullYear()}-#{date.getMonth()}-#{date.getDate()}")

    # Render a month from a Date object
    renderMonth: (monthDate) ->
      # Set month heading
      @monthHeader.text(DNM.util.Date.monthName(monthDate))
      @yearHeader.text(monthDate.getFullYear())

      html = ""
      for date in @datesForMonth(monthDate)
        html += @renderDate(date, monthDate)

      # Set the html in the days container
      @daysContainer.html(html)
      @reposition()

    # Get all the dates to render for a given month given that
    # all dates in a week must be rendered.
    datesForMonth: (monthDate) ->
      current = new Date(monthDate.getFullYear(), monthDate.getMonth(), 1, 0, 0, 0, 0)
      current.setDate(current.getDate() - current.getDay())

      weeks = 4
      weeks += 1 while new Date(current.getFullYear(), current.getMonth(), current.getDate()+weeks*7, 0, 0, 0, 0).getMonth() == monthDate.getMonth()

      dates = []
      for i in [0..(weeks*7-1)]
        dates.push new Date(current.getFullYear(), current.getMonth(), current.getDate()+i, 0, 0, 0, 0)
      dates

    renderDate: (date, monthDate) ->
      @_render(@dayTemplate,
        year:  date.getFullYear(),
        month: date.getMonth(),
        day:   date.getDate(),
        dow:   date.getDay(),
        klass: @classForDate(date, monthDate)
      )

    classForDate: (date, monthDate = null) ->
      klass = []
      klass.push "active" if @model.isSelected(date)
      klass.push "datepicker-day-other-month" if monthDate and monthDate.getMonth() != date.getMonth()

      now = new Date()
      now = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0)
      klass.push "datepicker-day-today" if date.getTime() == now.getTime()
      if date.getTime() < now.getTime()
        klass.push "datepicker-day-past"
        klass.push "disabled" if @options.disablePastDates
      klass.join ' '

    _render: (template, args) ->
      Mustache.render(template, args)






