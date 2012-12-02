class @Space.QuickBook

  constructor: (@form) ->
    @initializeCalendarField()

  initializeCalendarField: ->

    @form.find('.calendar input').datepicker(
      dateFormat: 'd M'
    ).change (event) =>
      values = @form.find('.calendar input').val()

    # Hack to only apply jquery-ui theme to datepicker
    $('#ui-datepicker-div').wrap('<div class="jquery-ui-theme" />')