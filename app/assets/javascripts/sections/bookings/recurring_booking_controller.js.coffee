# Controller for handling recurring booking subset of booking module

class Bookings.RecurringBookingController

  constructor: (@form) ->
    @weeklyRadioButton = @form.find('[data-recurring-weekly]')
    @customRadioButton = @form.find('[data-recurring-custom]')
    @recurringSelect = @form.find('.recurring_select')
    @firstTimeSelect = true

    @bindEvents()

  bindEvents: ->

    @weeklyRadioButton.on 'change', (event) =>
      @changeRecurringSelect('Weekly', @weeklyRadioButton) if @weeklyRadioButton.prop('checked')

    @customRadioButton.on 'change', (event) =>
      @changeRecurringSelect('Custom', @customRadioButton) if @customRadioButton.prop('checked')

    @recurringSelect.on 'recurring_select:cancel', =>
      @weeklyRadioButton.prop('checked', false).change()
      @customRadioButton.prop('checked', false).change()

    @recurringSelect.on 'recurring_select:save', (event, form_data) =>
      @form.find('.occurrences').val(form_data.occurrences)
      @form.find('.start_on').val(form_data.start_on)
      @form.find('.end_on').val(form_data.end_on)
      @form.find('.start_minute').val(form_data.start_at)
      @form.find('.end_minute').val(form_data.end_at)
      @form.find('.quantity').val(1)
      @form.submit()

  changeRecurringSelect: (text, button) ->
    if @form.data('registration-url')
      Modal.load(@form.data('registration-url'))
      @weeklyRadioButton.prop('checked', false).change()
      @customRadioButton.prop('checked', false).change()
    else
      if @firstTimeSelect
        @recurringSelect.trigger('focus')
        @firstTimeSelect = false
      option = @recurringSelect.find('option').filter ->
        return $(this).text().indexOf(text, 0) > -1
      option.prop('selected', true)
      @recurringSelect.trigger('change')

