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
        @view.show()

  bindViewEvents: ->
    @view.bind 'prevClicked', =>
      @model.advanceMonth(-1)

    @view.bind 'nextClicked', =>
      @model.advanceMonth(1)

    @view.bind 'dateClicked', (date) =>
      @model.toggleDate(date) if @model.canToggleDate(date)

  show: -> @view.show()
  hide: -> @view.hide()
  getDates: -> @model.getDates()

  class Datepicker.Model
    asEvented.call(Model.prototype)

    constructor: (options) ->
      @currentMonth = options.currentMonth
      @selectedDates = options.selectedDates
      @today = options.today

    advanceMonth: (incr = 1) ->
      @currentMonth = new Date(@currentMonth.getFullYear(), @currentMonth.getMonth()+incr, 1, 0, 0, 0, 0)
      @trigger('monthChanged', @currentMonth)

    isSelected: (date) ->
      including = false
      including = sd for sd in @selectedDates when sd.getMonth() == date.getMonth() && sd.getDate() == date.getDate() && sd.getFullYear() == date.getFullYear()
      including

    canToggleDate: (date) ->
      true

    getDates: ->
      @selectedDates.slice(0)

    toggleDate: (date) ->
      if @isSelected(date)
        @removeDate(date)
      else
        @addDate(date)

    removeDate: (date) ->
      including = @isSelected(date)
      return unless including

      @selectedDates.splice(@selectedDates.indexOf(including, 1))
      @trigger('dateRemoved', date)

    addDate: (date) ->
      @selectedDates.push(date)
      @trigger('dateAdded', date)


  # View renderer for the calendar
  class Datepicker.View
    asEvented.call(View.prototype)

    viewTemplate: '''
      <div class="datepicker-prev"></div>
      <div class="datepicker-next"></div>

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

    constructor: (@options = {}) ->
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

    show: ->
      # Refresh the view on the first display
      @refresh() if !@hasRendered
      @container.show()

    hide: ->
      @container.hide()

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

      # Render each day across the weeks
      start = new Date(monthDate.getFullYear(), monthDate.getMonth(), 1, 0, 0, 0, 0)
      start.setDate(start.getDate() - start.getDay())

      html = ""
      for i in [0..34]
        date = new Date(start.getFullYear(), start.getMonth(), start.getDate()+i, 0, 0, 0, 0)
        html += @renderDate(date)

      # Set the html in the days container
      @daysContainer.html(html)

    renderDate: (date) ->
      @_render(@dayTemplate,
        year:  date.getFullYear(),
        month: date.getMonth(),
        day:   date.getDate(),
        dow:   date.getDay(),
        klass: @classForDate(date)
      )

    classForDate: (date) ->
      klass = []
      klass.push "active" if @model.isSelected(date)
      klass.join ' '

    _render: (template, args) ->
      Mustache.render(template, args)






