Modal = require('../../components/modal')

# Controller for handling recurring booking subset of booking module

module.exports = class BookingsRecurringBookingController

  constructor: (@form) ->
    @weeklyRadioButton = @form.find('[data-recurring-weekly]')
    @RadioButton = @form.find('[data-recurring-monthly]')
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
      @updateRecurringForm()

  # This function is used to populated the upsell charges into the recurringForm
  updateRecurringForm: ->
    @recurringDialog = $('.rs_dialog_content')
    @updateAdditionalCharges()

  updateAdditionalCharges: ->
    additionalChargesArea       = $('#additional_charges')
    recurringChargesArea        = $('.recurring-booking form #recurring-charges')
    recurringBookingFormSummary = @recurringDialog.find('.rs_summary')

    recurringBookingFormSummary.before(additionalChargesArea.clone())
    recurringChargesArea.append(additionalChargesArea.find('input[type=checkbox]').clone())

    # Binding event that will copy all of the updated checkboxes with charges to the main recurring form
    additionalChargeCheckboxes = @recurringDialog.find("#additional_charges input[type=checkbox]")
    additionalChargeCheckboxes.on 'change', (event) ->
      additionalChargeFields = $(".rs_dialog_content #additional_charges input[type=checkbox")
      recurringChargesArea.empty()
      recurringChargesArea.append(additionalChargeFields.clone())
