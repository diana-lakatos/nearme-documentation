module.exports = class SearchDatepickers
  constructor: (@container = nil) ->
    if @container
      @start_date = @container.find('[name="start_date"]')
      @end_date = @container.find('[name="end_date"]')
      if @start_date.length > 0 && @end_date.length > 0
        @initializeDatepickers()

  initializeDatepickers: ->
    common_options = {
      altFormat: 'yy-mm-dd',
      dateFormat: 'mm/dd/yy',
      constrainInput: true,
      minDate: 0
    }
    @container.find('[name="start_date"], [name="fake_start_date"]').datepicker($.extend({}, common_options, {
      altField: @container.find('[name="availability[dates][start]"]'),
      showOtherMonths: true,
      selectOtherMonths: true,
      onClose: (selectedDateString) =>
        selectedDate = new Date(selectedDateString)
        if selectedDate > new Date(@end_date.val()) || selectedDate > new Date(@container.find('[name="fake_end_date"]').val())
          newEndDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate() + 1)
          @container.find('[name="end_date"], [name="fake_end_date"]').datepicker('setDate', newEndDate)
    }));

    @container.find('[name="end_date"], [name="fake_end_date"]').datepicker($.extend({}, common_options, {
      altField: @container.find('[name="availability[dates][end]"]'),
      defaultDate: 1,
      showOtherMonths: false,
      selectOtherMonths: false,
      onClose: (selectedDateString) =>
        selectedDate = new Date(selectedDateString)
        if selectedDate < new Date(@start_date.val()) || selectedDate < new Date(@container.find('[name="fake_start_date"]').val())
          newStartDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate() - 1)
          @container.find('[name="start_date"], [name="fake_start_date"]').datepicker('setDate', newStartDate)
    }));
    @start_date.datepicker('setDate', new Date());
    @end_date.datepicker('setDate', 1);
