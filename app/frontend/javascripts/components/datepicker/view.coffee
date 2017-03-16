asEvented = require('asevented')
dateUtil = require('../../lib/utils/date')

PositionedView = require ('../lib/positioned_view')

# Internal display view for datepicker
module.exports = class DatepickerView extends PositionedView
  asEvented.call @prototype

  viewTemplate: '''
    <div class="datepicker-prev ico-arrow-left"></div>
    <div class="datepicker-next ico-arrow-right"></div>

    <div class="datepicker-header">
      <div class="datepicker-month"></div>
      <div class="datepicker-year"></div>
    </div>

    <div class="datepicker-text">
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
    <div title="<%= title %>" class="<%= klass %>" data-year="<%= year %>" data-month="<%= month %>" data-day="<%= day %>"><%= day %></div>
  '''

  defaultOptions: {
    containerClass: 'dnm-datepicker',

    # Target for positioning of the popover view
    positionTarget: null,

    # Padding in px as spacing around the positioning popover
    positionPadding: 5,

    # Whether to disable past dates
    disablePastDates: true,

    # How many pixels away from the right of the window to force
    # the datepicker to render.
    windowRightPadding: 20
  }

  constructor: (@options = {}) ->
    @options = $.extend({}, @defaultOptions, @options)
    @options.positionTarget ||= @options.trigger
    super(@options)

    @container.html(@viewTemplate)
    @monthHeader = @container.find('.datepicker-month')
    @yearHeader  = @container.find('.datepicker-year')
    @prev = @container.find('.datepicker-prev')
    @next = @container.find('.datepicker-next')
    @weekHeader = @container.find('.datepicker-week-header')
    @daysContainer = @container.find('.datepicker-days')
    @loading = @container.find('.datepicker-loading').hide()
    @setText(@options.text) if @options.text
    @bindEvents()

  # Set the model for the view
  setModel: (model) ->
    @model = model

  setText: (text) ->
    @container.find('.datepicker-text').html(text)

  show: ->
    # Refresh the view on the first display
    @refresh() if !@hasRendered
    super

  dateAdded: (date) ->
    @updateDate(date)

  dateRemoved: (date) ->
    @updateDate(date)

  updateDate: (date) ->
    klass = @classForDate(date, @model.getCurrentMonth())
    @dateElement(date).removeClass().addClass(klass)

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

  # Render all state again
  refresh: ->
    @activeDate = null
    @firstUnavailable = null
    @renderMonth(@model.getCurrentMonth())
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
    @firstUnavailable = null

    @monthHeader.text(dateUtil.monthName(monthDate))
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
    # Standard date classes
    klass = [
      'datepicker-day',
      "datepicker-day-#{date.getFullYear()}-#{date.getMonth()}-#{date.getDate()}",
      "datepicker-day-dow-#{date.getDay()}"
    ]

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
    _.template(template)(args)

