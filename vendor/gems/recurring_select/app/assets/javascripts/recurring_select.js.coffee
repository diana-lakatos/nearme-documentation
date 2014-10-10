//= require recurring_select_dialog
//= require_self

$ = jQuery
$ ->
  $(document).on "focus", ".recurring_select", ->
    $(this).recurring_select('set_initial_values')

  $(document).on "change", ".recurring_select", ->
    $(this).recurring_select('changed')

methods =
  set_initial_values: ->
    @data 'initial-value-hash', @val()
    @data 'initial-value-str', $(@find("option").get()[@.prop("selectedIndex")]).text()

  changed: ->
    if @val() == "custom"
      @data 'initial-value-hash', $(@find("option").eq(@find("option").length-3)).val()
      @data 'initial-value-str', $(@find("option").eq(@find("option").length-3)).text()
    else
      methods.set_initial_values.apply(@)
    methods.open_custom.apply(@)

  open_custom: ->
    @data "recurring-select-active", true
    new RecurringSelectDialog(@, {hourly: @closest('form').data('hourly')})
    @blur()

  save: (new_rule, form_data = {}) ->
    @find("option[data-custom]").remove()
    new_json_val = JSON.stringify(new_rule.hash)

    # TODO: check for matching name, and replace that value if found

    if $.inArray(new_json_val, @find("option").map -> $(@).val()) == -1
      methods.insert_option.apply @, [new_rule.str, new_json_val]

    @val new_json_val
    methods.set_initial_values.apply @
    @.trigger "recurring_select:save", form_data

  current_rule: ->
    str:  @data("initial-value-str")
    hash: $.parseJSON(@data("initial-value-hash"))

  cancel: ->
    @val @data("initial-value-hash")
    @data "recurring-select-active", false
    @.trigger "recurring_select:cancel"


  insert_option: (new_rule_str, new_rule_json) ->
    separator = @find("option:disabled")
    if separator.length == 0
      separator = @find("option")
    separator = separator.last()

    new_option = $(document.createElement("option"))
    new_option.attr "data-custom", true

    if new_rule_str.substr(new_rule_str.length - 1) != "*"
      new_rule_str+="*"

    new_option.text new_rule_str
    new_option.val new_rule_json
    new_option.insertBefore separator

  methods: ->
    methods

$.fn.recurring_select = (method) ->
  if method of methods
    return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ) );
  else
    $.error( "Method #{method} does not exist on jQuery.recurring_select" );

$.fn.recurring_select.texts = {
  repeat: "REPEAT"
  last_day: "Last Day"
  frequency: "Frequency"
  daily: "Daily"
  weekly: "Weekly"
  monthly: "Monthly"
  yearly: "Yearly"
  every: "Repeat every"
  every_on: "Repeat on"
  every_by: "Repeat by"
  days: "days"
  weeks: "weeks"
  months: "month"
  years: "years"
  day_of_month: "Day of month"
  day_of_week: "Day of week"
  cancel: "CANCEL"
  ok: "OK"
  on: "On"
  to: "to"
  starts_on: "Starts on"
  from: "From"
  ends: "Ends"
  never: "Never"
  after: "After"
  occurrences: "occurrences"
  summary: "Summary"
  first_day_of_week: 0
  days_first_letter: ["S", "M", "T", "W", "T", "F", "S" ]
  order: ["1st", "2nd", "3rd", "4th"]
}
