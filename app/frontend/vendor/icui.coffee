require('strftime')
# ICUI
# ====
#
# ICUI is a user interface componenet for constructing repetion
# schedules for the Ruby [IceCube](https://github.com/seejohnrun/ice_cube)
# library.

do ($ = jQuery) ->
  # Helpers
  # -------
  Helpers =
    # `clone` will make a copy of an object including all child object.
    clone: clone = (obj) ->
      if not obj? or typeof obj isnt 'object'
        return obj

      if obj instanceof Date
        return new Date(obj.getTime())

      if obj instanceof RegExp
        flags = ''
        flags += 'g' if obj.global?
        flags += 'i' if obj.ignoreCase?
        flags += 'm' if obj.multiline?
        flags += 'y' if obj.sticky?
        return new RegExp(obj.source, flags)
      # Some care is taken to avoid cloning the parent class,
      # as each ICUI object holds both a reference to a child objects
      # as well as to it's own parent, which could is a cyclic reference.
      if obj.parent? && obj.data?
        # A special case `__clone` parameter is passed to constructors
        # so as to be able to avoid actual initialization.
        newInstance = new obj.constructor(obj.parent, '__clone')
        newInstance.data = clone obj.data
      else
        newInstance = new obj.constructor()
      for own key of obj when key not in ['parent', 'data', 'elem'] and typeof obj[key] != 'function'
        newInstance[key] = clone obj[key]

      return newInstance
    # `option` constructs an option for a select where it handles the
    # case when to add the `selected` attribute. The third argument can
    # optionally be a function, otherwise it compare the third argument
    # with the first and if equal mark the option as selected.
    option: (value, name, varOrFunc) ->
      if typeof varOrFunc == 'function'
        selected = varOrFunc(value)
      else
        selected = varOrFunc == value
      """<option value="#{value}"#{
        if selected then ' selected="selected"' else ""
      }>#{name}</option>"""

    # `select` will genearate a `<select>` tag.
    select: (varOrFunc, obj) ->
      str = "<select>"
      str += Helpers.option value, label, varOrFunc for value, label of obj
      str + "</select>"

    daysOfTheWeek: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    # THis is a wrapper for the most ridicilous API in probably the whole of
    # JavaScript.
    dateFromString: (str) ->
      unless typeof str == 'string'
        str = str.time
      [date, time] = str.split(/[\sT]/)
      [y, m, d] = (parseInt(t, 10) for t in date.split('-'))
      [h, min, rest...] = (parseInt(t, 10) for t in time.split(':'))
      m = if m - 1 >= 0 then m - 1 else 11
      tz = (new Date).getTimezoneOffset()
      new Date(Date.UTC(y, m, d, h, min, 0, 0))

  # The Base Class
  # --------------
  #
  # Option is the class from which nearly all other classes in ICUI
  # inherit. A number of function are meant to be overriden.
  class Option

    constructor: (@parent, data = null) ->
      @children = []
      @data = {}
      if data != '__clone'
        if data? then @fromData(data) else @defaults()
    # `fromData` is meant as an initializer to which the relevant part
    # of the JSON representation is passed at startup.
    fromData: (data) ->
    # Defaults is the initializer used typically for instances constructed
    # as the default child of a parent.
    defaults: ->
    # When `clonable` is `true` the + button will appear.
    clonable: -> true
    # When `destroyable` is `true` the - button will appear.
    destroyable: -> @parent.children.length > 1
    # `clone` is the event handler that will insert a copy of the
    # reciever as a sibling to the reciever.
    clone: =>
      @parent.children.push Helpers.clone @
      @triggerRender()
    # `destroy` will remove the reciever from it's parents list
    # of children.
    destroy: =>
      @elem.slideUp 100, =>
        @parent.children.splice(@parent.children.indexOf(@), 1)
        if this instanceof TopLevel
          for child in @parent.children when child instanceof TopLevel
              has_negative_rules = child if child.isNegative()
              has_positive_rules = child if child.isPositive()
          @parent.has_negative_rules = no unless has_negative_rules?
          @parent.has_positive_rules = no unless has_positive_rules?
        @parent.has_ending_time = no if this instanceof EndTime
        @parent.triggerRender()

    # Render is the code that is responsible for setting up an
    # HTML fragment and binding all the necessary UI callbacks
    # onto it. It is recommended to call super as this will make
    # all the child objects render as wall as displays the generic
    # cloning UI.
    render: ->
      out = $ "<div></div>"
      buttons = $ "<div class='col-md-2 small-padding text-right'></div>"
      buttons.append $("<span class='btn clone'>+</span>").click(@clone) if @clonable()
      buttons.append $("<span class='btn destroy'>-</span>").click(@destroy) if @destroyable()
      out.append buttons
      out.append @renderChildren()
      out.children() # <- get's rid of the container div

    renderChildren: -> c.render() for c in @children
    # This will trigger a rerender for the whole structure without needing
    # to keep a global reference to the root node.
    triggerRender: -> @parent.triggerRender()

  # The Root Node
  # -------------
  #
  # `Root` is meant as a singleton class (although this is not enforced).
  # It holds inside itself all other nodes and is responsible for actually
  # putting the whole structure into the DOM.
  class Root extends Option
    clonable: -> no
    destroyable: -> no
    has_ending_time: no
    has_positive_rules: no
    has_negative_rules: no

    constructor: ->
      super
      # The parent of the root node is the jQuerified element
      # itself, this will typically be an `<input type="hidden">`.
      # We insert our container div after it and save it into the
      # `@target` variable.
      @parent.after "<div class='icui'><div class='positive-rules'></div><div class='negative-rules'></div></div>"
      @target = @parent.siblings('.icui')
      @positive_target = @target.find('.positive-rules').first()
      @negative_target = @target.find('.negative-rules').first()

    fromData: (d) ->
      @children.push new StartDate(@, d["start_date"])
      if d["end_time"]
        @has_ending_time = yes
        @children.push new EndTime(@, d["end_time"])
      for k,v of d when v.length > 0 and k != "start_date" and k != "end_time" and k != "start_time"

        if k.match /^r/
          @has_positive_rules = yes
        else if k.match /^ex/
          @has_negative_rules = yes

        @children.push new TopLevel(@, {type: k, values: v})


    defaults: ->
      @children.push new StartDate(@)
      #@children.push new TopLevel(@)

    triggerRender: -> @render()

    render: ->
      @positive_target.html(@renderPositiveChildren())
      @negative_target.html(@renderNegativeChildren())
      unless @has_ending_time || true
        link = $("<div class='row'><a href='#'>#{@parent.data('add-duration')}</a></div> ")
        link.click =>
          @has_ending_time = yes
          link.hide()
          @children.push new EndTime(@)
          @triggerRender()
          false
        @positive_target.append(link)
      unless @has_positive_rules
        positive_link = $("<div class='row'><a href='#'>#{@parent.data('add-availability')}</a></div>")
        positive_link.click =>
          @has_positive_rules = yes
          positive_link.hide()
          @children.push new TopLevel(@)
          @triggerRender()
          false
        @positive_target.append(positive_link)
      unless @has_negative_rules
        negative_link = $("<div class='row'><a href='#'>#{@parent.data('add-unavailable')}</a></div>")
        negative_link.click =>
          @has_negative_rules = yes
          negative_link.hide()
          top_level = new TopLevel(@)
          top_level.data.type = 'extimes'
          top_level.children = [new DatePicker top_level]
          @children.push top_level
          @triggerRender()
          false
        @negative_target.append(negative_link)
      ''

    renderPositiveChildren: ->
      arr = []
      arr.push $("<h4>#{@parent.data('availability')}</h4>")
      for child in @children
        arr.push child.render() unless child instanceof TopLevel && child.isNegative()
      arr

    renderNegativeChildren: ->
      arr = []
      arr.push $("<h4>#{@parent.data('unavailable')}</h4>")
      for child in @children
        arr.push child.render() if child instanceof TopLevel && child.isNegative()
      arr

    getData: ->
      data = {}
      for child in @children
        d = child.getData()
        if data[d.type]
          data[d.type] = data[d.type].concat(d.values)
        else
          data[d.type] = d.values
      data


  # TopLevel
  # --------
  # The `TopLevel` class let's the user pick whether he would like
  # to add or remove dates or rules.
  #
  # Each of these alternatives than spawns a default child.
  #
  # The total class diagram looks like this:
  #
  #     Root
  #     |- StartDate
  #     `- TopLevel +-
  #        |- DatePicker +-
  #        `- Rule +-
  #           `- Validation +-
  #              |- Count
  #              |- Until
  #              |- Day +-
  #              |- HourOfDay +-
  #              |- MinuteOfHour +-
  #              |- DayOfWeek +-
  #              |- DayOfMonth +-
  #              |- DayOfYear +-
  #              `- OffsetFromPascha +-
  class TopLevel extends Option

    defaults: ->
      @data.type = 'rrules'
      @children = [new Rule @]

    fromData: (d) ->
      @data.type = d.type
      if @data.type.match /times$/
        for v in d.values
          @children.push new DatePicker @, v
      else
        for v in d.values
          @children.push new Rule @, v

    getData: ->
      if @data.type.match /times$/
        values = (child.getData().time for child in @children)
        {type: @data.type, values}
      else
        values = (child.getData() for child in @children)
        {type: @data.type, values}

    isPositive: ->
      @data.type.match /^r/

    isNegative: ->
      @data.type.match /^ex/

    render: ->
      @elem = $("""
    <div class="toplevel">
      <div class='row'>
        <div class="col-md-2 label"><label>#{@parent.parent.data('event')}</label></div>
        <div class="col-md-4 small-padding hidden">
          <select class="select required selectpicker">
            #{Helpers.option 1, "occurs", => @data.type.match /^r/}
            #{Helpers.option -1, "doesn't occur", => @data.type.match /^ex/}
          </select>
        </div>
        <div class="col-md-8 small-padding big-input">
          <select>
            #{Helpers.option 'dates', "#{@parent.parent.data('specific-dates')}", => @data.type.match /times$/}
            #{Helpers.option 'rules', "#{@parent.parent.data('every')}", => @data.type.match /rules$/}
          </select>
        </div>
      </div>
    </div>
    """)
      ss = @elem.find('select')
      ss.first().change (e) =>
        if e.target.value == '1'
            @data.type = @data.type.replace /^ex/, 'r'
        else
          @data.type = @data.type.replace /^r/, 'ex'
      ss.last().change (e) =>
        if e.target.value == 'dates'
          if @data.type.match /^r/
            @data.type = 'rtimes'
          else
            @data.type = 'extimes'
          @children = [new DatePicker @]
        else
          if @data.type.match /^r/
            @data.type = 'rrules'
          else
            @data.type = 'exrules'
          @children = [new Rule @]
        @triggerRender()
      row = @elem.find('div.row')
      children = super.toArray()
      row.append children.shift()
      @elem.append children
      if $.prototype.selectpicker?
        @elem.find('select').selectpicker()
      @elem

  # Choosing Individual DateTimes
  # -----------------------------
  #
  # The DatePicker class allows the user to pick an individual date and
  # time. Currently it relies on HTML5 attributes to provide most of the
  # user interface, however we could probably easily extend this to use
  # something like jQuery UI.
  class DatePicker extends Option
    defaults: -> @data.time ?= new Date

    fromData: (d) -> @data.time = Helpers.dateFromString d

    getData: -> @data
    render: ->
      @elem = $("""
        <div class="DatePicker row">
          <div class="col-md-2 label">
            <label>#{@getData().label || ''}</label>
          </div>
          <div class="col-md-4 small-padding">
            <input type="text" data-type="date" value="#{@data.time.strftime('%Y-%m-%d')}" />
          </div>
          <div class="col-md-4 small-padding">
            <input type="time" value="#{@data.time.strftime('%H:%M')}" />
          </div>
        </div>
      """)
      ss = @elem.find('input')
      date = ss.first()
      time = ss.last()
      ss.change (e) =>
        @data.time = Helpers.dateFromString date.val() + ' ' + time.val()
      @elem.find("input[data-type='date']").datepicker(
        dateFormat: "yy-mm-dd",
        altFormat: "yy-mm-dd"
      )
      @elem.append super
      @elem

  # Picking the initial Date
  # ------------------------
  # `StartDate` is a concrete DatePicker subclass that takes care of picking
  # the initial date. The main diffrence is that it is unclonable.
  class StartDate extends DatePicker
    destroyable: -> false
    clonable: -> false
    getData: ->
      {type: "start_date", values: @data.time, label: @parent.parent.data('start-time')}
    render: ->
      @elem = super
      @elem

  # Picking the ending Date
  # -----------------------
  # `EndTime` is a concrete DatePicker subclass that takes care of picking
  # the ending date. The main diffrence is that it is unclonable.
  class EndTime extends DatePicker
    destroyable: -> true
    clonable: -> false
    getData: -> {type: "end_time", values: @data.time, label: @parent.parent.data('duration')}

    render: ->
      @elem = super
      @elem

  # Specifying Rules
  # ----------------
  # Rules specify a sort of generator which than validations filter out.
  # So the `YearlyRule` will generate thing which happen roughly once per
  # year.
  class Rule extends Option

    defaults: ->
      @data.rule_type = 'IceCube::WeeklyRule'
      @children = [new Validation @]
      @data.interval = 1

    fromData: (d)->
      @data.rule_type = d.rule_type
      @data.interval = d.interval
      if d.count
        @children.push new Validation @, {type: 'count', value: d.count}
      if d.until
        @children.push new Validation @, {type: 'until', value: d.until}
      for k, v of d.validations
        @children.push new Validation @, {type: k, value: v}

    getData: ->
      validations = {}
      for child in @children when child.data.type isnt 'count' and child.data.type isnt 'until'
        for k,v of child.getData()
          validations[k] = v
      h = {rule_type: @data.rule_type, interval: @data.interval, validations}
      for child in @children when child.data.type is 'count' or child.data.type is 'until'
        for k,v of child.getData()
          h[k] = v
      h

    render: ->
      @elem = $("""
        <div class="Rule">
          <div class="row">
            <div class="col-md-2"></div>
            <div class="col-md-4 small-padding">
              <input type="number" value="#{@data.interval}" size="2" width="30" min="1" />
            </div>
            <div class="col-md-4 small-padding">
              #{Helpers.select @data.rule_type,
              "IceCube::YearlyRule": 'years'
              "IceCube::MonthlyRule": 'months'
              "IceCube::WeeklyRule": 'weeks'
              "IceCube::DailyRule": 'days',
              }
            </div>
          </div>
        </div>
      """)
      @elem.find('input').change (e) =>
        @data.interval = parseInt e.target.value
      @elem.find('select').change (e) =>
        @data.rule_type = e.target.value
        if @data.rule_type == 'IceCube::HourlyRule'
          @children = [new Validation @, { type: 'count' }]
        else
          @children = [new Validation @]
        @triggerRender()
      row = @elem.find('div.row')
      children = super.toArray()
      row.append children.shift()
      @elem.append children
      @elem

  # Validation
  # ----------
  # Validation let's the user pick what type of validation to use
  # and also agregates the arguments to the validation.
  class Validation extends Option
    defaults: ->
      @data.type = 'day'
      @children = [new Day @]

    fromData: (d) ->
      @data.type = d.type
      switch d.type
        when 'count' then @children.push new Count @, d.value
        when 'until' then @children.push new Until @, d.value
        when 'day'
          for v in d.value
            @children.push new Day @, v
        when 'day_of_week'
          for k,vals of d.value
            for v in vals
              @children.push new DayOfWeek @, {nth: v, day: k}
        else
          for v in d.value
            klass = @choices(d.type)
            c = new klass @, v
            @children.push c

    choices: (v) ->
      {
        count: Count
        until: Until
        day:   Day
        hour_of_day: HourOfDay
        minute_of_hour: MinuteOfHour
        day_of_week: DayOfWeek
        day_of_month: DayOfMonth
        day_of_year: DayOfYear
        offset_from_pascha: OffsetFromPascha
      }[v]

    getData: ->
      key = @data.type
      value = switch key
        when 'count' then @children[0].getData()
        when 'until' then @children[0].getData()
        when 'day_of_week'
          obj = {}
          for child in @children
            [k,v] = child.getData()
            obj[k] ?= []
            obj[k].push v
          obj
        else child.getData() for child in @children
      obj = {}
      obj[key] = value
      obj

    destroyable: -> true
    render: ->
      translation_holder = (if @parent.parent then (if @parent.parent.parent then @parent.parent.parent else @parent.parent) else @parent).parent
      str = """
      <div class="Validation">
        <div class="row">
          <div class="col-md-2 label">
            <label>#{if @parent.children.indexOf(@) > 0 then "and if" else "If"}</label>
          </div>
          <div class="col-md-8 small-padding">
            <select>
              #{Helpers.option "count", translation_holder.data('event-occured-less'), @data.type}"""
      if @parent.data.rule_type in ["IceCube::YearlyRule", "IceCube::MonthlyRule", "IceCube::WeeklyRule", "IceCube::DailyRule", "IceCube::HourlyRule"]
        str += Helpers.option "until", translation_holder.data('event-before'), @data.type
        str += Helpers.option "day", translation_holder.data('this-day-of-week'), @data.type
        str += Helpers.option "hour_of_day", translation_holder.data('this-hour-of-day'), @data.type
        str += Helpers.option "minute_of_hour", translation_holder.data('this-minute-of-hour'), @data.type
      if @parent.data.rule_type in ["IceCube::YearlyRule", "IceCube::MonthlyRule"]
        str += Helpers.option "day_of_week", translation_holder.data('this-day-of-nth-week'), @data.type
        str += Helpers.option "day_of_month", translation_holder.data('this-nth-day-of-month'), @data.type
      if @parent.data.rule_type is "IceCube::YearlyRule"
        str += Helpers.option "day_of_year", translation_holder.data('this-nth-day-of-year'), @data.type
        str += Helpers.option "offset_from_pascha", translation_holder.data('pascha-offset'), @data.type
      str += """
            </select>
          </div>
        <div>
      </div>
      """
      @elem = $(str)
      @elem.find('select').change (e) =>
        # switch e.target.value
        #          when 'count' then @children = [new Count @]
        #          when 'day' then @children = [new Day @]
        #          when 'day_of_week' then @children = [new DayOfWeek @]
        #          when 'day_of_month' then @children = [new DayOfMonth @]
        #          when 'day_of_year' then @children = [new DayOfYear @]
        #          when 'offset_from_pascha' then @children = [new OffsetFromPascha @]
        klass = @choices(e.target.value)
        @children = [new klass @]
        @data.type = e.target.value
        @triggerRender()
      row = @elem.find('div.row')
      children = super.toArray()
      row.append children.shift()
      @elem.append children
      @elem

  # Validation Types
  # ================
  # we have a seperate class for each type of validation that the
  # user can pick with `Validation`.
  #
  # Validation Instance
  # -------------------
  # ValidationInstance is a base class for some of the simpler
  # validation types (typically those with a single parameter).
  class ValidationInstance extends Option
    defaults: -> @data.value = @default
    fromData: (d) -> @data.value = d
    getData: -> @data.value
    # `dataTransformer` is what transforms the string representation
    # of the UI into a js datastructure. It is by default `parseInt`.
    dataTransformer: parseInt
    default: 1
    # The `render` implementation relies on a `html` method that returns
    # an HTML string.
    render: ->
      @elem = $ @html()
      @elem.find('input,select').change (e) =>
        @data.value = @dataTransformer(e.target.value)
      row = @elem.find('div.row')
      children = super.toArray()
      row.append children.shift()
      @elem
  # Count
  # -----
  # Count will limit the maximum times an event can repeat.
  class Count extends ValidationInstance
    clonable: -> false
    html: -> """
      <div class="row">
        <div class="col-md-2 label"><label></label></div>
        <div class="Count col-md-8 small-padding">
          <input type="number" value=#{@data.value} /> times.
        </div>
        <div class="col-md-2 label"><label></label></div>
      </div>
      """
  # Until
  # -----
  # Until will repeat the event until a specified date.
  class Until extends DatePicker
    getData: -> @data.time
    clonable: -> false
    destroyable: -> false


  # Hour of Day
  # ------------
  # Hour of day overwrites start time and allows for multiple occurrences during same day
  class HourOfDay extends ValidationInstance
    html: ->
      str = """
      <div class="HourOfDay">
        <div class="row">
          <div class="col-md-2 label"><label></label></div>
          <div class="col-md-8 small-padding">
            <select>"""
      for i in [0..11]
        str += Helpers.option i.toString(), "#{if i == 0 then 12 else i} AM", @data.value.toString()
      for i in [12..23]
        str += Helpers.option (i).toString(), "#{if i == 12 then 12 else i - 12} PM", @data.value.toString()
      str +=  """</select> hour of day.
          </div>
        </div>
      </div>
      """

  # Minute of hour
  # ------------
  # minute of hour overwrites start time and allows for multiple occurrences within an hour
  class MinuteOfHour extends ValidationInstance
    html: ->
      str = """
      <div class="HourOfDay">
        <div class="row">
          <div class="col-md-2 label"><label></label></div>
          <div class="col-md-8 small-padding">
            <select>"""
      for i in [0..59]
        str += Helpers.option i.toString(), "#{i}", @data.value.toString()
      str +=  """</select> minute of hour.
          </div>
        </div>
      </div>
      """

  # Day of Month
  # ------------
  # Day of month filters out days that are not the nth day of the month.
  class DayOfMonth extends ValidationInstance
    html: ->
      pluralize = (n) -> switch (if 10 < n < 20 then 4 else n % 10)
        when 1 then 'st'
        when 2 then 'nd'
        when 3 then 'rd'
        else 'th'
      str = """
      <div class="DayOfMonth">
        <div class="row">
          <div class="col-md-2 label"><label></label></div>
          <div class="col-md-8 small-padding">
            <select>"""
      for i in [1..31]
        str += Helpers.option i.toString(), "#{i}#{pluralize i}", @data.value.toString()
      str += Helpers.option "-1", "last", @data.value.toString()
      str +=  """</select> day of the month.
          </div>
        </div>
      </div>
      """
  # Day
  # ---
  # Day let's the user filter events occuring on particular days of the
  # week.
  class Day extends ValidationInstance
    html: ->
      str = """
      <div class="Day">
        <div class="row">
          <div class="col-md-2 label"><label></label></div>
          <div class="col-md-8 small-padding">
            <select>"""
      for day, i in Helpers.daysOfTheWeek
        str += Helpers.option i.toString(), day, @data.value.toString()
      str +=  """
            </select>
          </div>
        </div>
      </div>
      """
  # Day of Week
  # -----------
  # This is the perhaps most confusing rule. It allows the user to
  # specify thing like "the 3rd sunday of the month" and so on.
  class DayOfWeek extends Option
    getData: -> [@data.day, @data.nth]
    fromData: (@data) ->
    defaults: ->
      @data.nth = 1
      @data.day = 0
    render: ->
      str = """
      <div class="DayOfWeek">
        <div class="row">
          <div class="col-md-2 label"><label><label></div>
          <div class="col-md-4 small-padding">
              <input type="number" value=#{@data.nth} /><span>nth</span>.
          </div>
          <div class="col-md-4 small-padding">
            <select>
      """
      for day, i in Helpers.daysOfTheWeek
        str += Helpers.option i.toString(), day, @data.day.toString()
      str +=  "
            </select>
          </div>
        </div>
      </div>"
      @elem = $ str
      pluralize = => @elem.find('span').first().text switch @data.nth
        when 1 then 'st'
        when 2 then 'nd'
        when 3 then 'rd'
        else 'th'
      @elem.find('input').change (e) =>
        @data.nth = parseInt e.target.value
        pluralize()
      @elem.find('select').change (e) =>
        @data.day = parseInt e.target.value
      row = @elem.find('div.row')
      children = super.toArray()
      row.append children.shift()
      pluralize()
      @elem

  # Day of Year
  # -----------
  # Allows to specify a particular day of the year.
  class DayOfYear extends Option
    getData: -> @data.value
    fromData: (d) -> @data.value = d
    defaults: -> @data.value = 1
    render: ->
      str = """
      <div class="DayOfYear">
        <div class="row">
          <div class="col-md-2 label"><label><label></div>
          <div class="col-md-4 small-padding">
            <input type="number" value=#{Math.abs @data.value} /> day from the
          </div>
          <div class="col-md-4 small-padding">
            <select>
              #{Helpers.option '+', 'beginning', => @data.value >= 0}
              #{Helpers.option '-', 'end', => @data.value < 0}
            </select> of the year.
          </div>
        </div>
      </div>
      """
      @elem = $ str
      @elem.find('input,select').change (e) =>
        @data.value = parseInt @elem.find('input').val()
        @data.value *= if @elem.find('select').val() == '+' then 1 else -1
      row = @elem.find('div.row')
      children = super.toArray()
      row.append children.shift()
      @elem

  # Offset from Pascha
  # ------------------
  # This class allows the user to specify dates in relation to the
  # Orthodox celebration of Easter, Pascha.
  class OffsetFromPascha extends Option
    getData: -> @data.value
    defaults: -> @data.value = 0

    fromData: (d) -> @data.value = d

    render: ->
      str = """
      <div class="OffsetFromPascha">
        <div class="row">
          <div class="col-md-2 label"><label><label></div>
          <div class="col-md-4 small-padding">
            <input type="number" value=#{Math.abs @data.value} /> days
          </div>
          <div class="col-md-4 small-padding">
            <select>
              #{Helpers.option '+', 'after', => @data.value >= 0}
              #{Helpers.option '-', 'before', => @data.value < 0}
            </select> Pascha.
          </div>
        </div>
      </div>
      """
      @elem = $ str
      @elem.find('input,select').change (e) =>
        @data.value = parseInt @elem.find('input').val()
        @data.value *= if @elem.find('select').val() == '+' then 1 else -1
      row = @elem.find('div.row')
      children = super.toArray()
      row.append children.shift()
      @elem

  # ICUI
  # ----
  # This is the class that is responsible for initializing the whole
  # hierarchy and also setting up the form to retrieve the correct
  # representation.
  class ICUI
    constructor: ($el, opts) ->
      container = $el.closest('div[data-schedule-wrapper]')
      simple_schedule = container.find('div[data-simple-schedule]')
      advanced_schedule = container.find('div[data-advanced-schedule]')
      simple_schedule_radio = simple_schedule.find('input[data-simple-schedule-radio]')
      advanced_schedule_radio = advanced_schedule.find('input[data-simple-schedule-radio]')
      between_hours = container.find('[data-between-hours]')
      hours_input = container.find('input[data-hours]')

      if parseInt(hours_input.val(), 10) > 0
        between_hours.show()
      else
        between_hours.hide()

      container.find('a[data-toggler]').on 'click', (event) ->
        event.preventDefault()
        simple_schedule_radio.prop('checked', !simple_schedule_radio.prop('checked'))
        advanced_schedule_radio.prop('checked', !simple_schedule_radio.prop('checked'))
        advanced_schedule.toggle()
        simple_schedule.toggle()

      hours_input.on 'blur', (event) ->
        if parseInt($(event.target).val(), 10) > 0
          between_hours.show()
        else
          between_hours.hide()

      data = try
        JSON.parse($el.val())
      catch e
        null

      @root = new Root $el, data
      $el.parents('form').on 'submit', (e) =>
        if opts['submit']
          opts.submit(@getData())
          e.preventDefault()
          return false
        else
          $el.val JSON.stringify @getData()
      $el.after @root.render()

    getData: ->
      @root.getData()

  # The jQuery Plugin
  # -----------------
  # Aceepts an options object where future configuration can go in.
  # Currently suports only a 'submit' key, which is a function called
  # on submitting the form.
  $.fn.icui = (opts = {}) ->
    @.each ->
      new ICUI $(@), opts
