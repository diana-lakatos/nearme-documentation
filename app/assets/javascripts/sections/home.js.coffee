#= require_self
#= require ./home/background_controller
#= require ./home/controller

@Home = {}

common_options = {
  altFormat: 'yy-mm-dd',
  dateFormat: 'mm/dd/yy',
  constrainInput: true,
  minDate: 0
}

$('#start_date, #fake_start_date').datepicker($.extend({}, common_options, {
  altField: '#availability_dates_start',
  showOtherMonths: true,
  selectOtherMonths: true,
  onClose: (selectedDateString) ->
    selectedDate = new Date(selectedDateString)
    if selectedDate > new Date($('#end_date').val()) || selectedDate > new Date($('#fake_end_date').val())
      newEndDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate() + 1)
      $('#end_date, #fake_end_date').datepicker('setDate', newEndDate)
}));

$('#end_date, #fake_end_date').datepicker($.extend({}, common_options, {
  altField: '#availability_dates_end',
  defaultDate: 1,
  showOtherMonths: false,
  selectOtherMonths: false,
  onClose: (selectedDateString) ->
    selectedDate = new Date(selectedDateString)
    if selectedDate < new Date($('#start_date').val()) || selectedDate < new Date($('#fake_start_date').val())
      newStartDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate() - 1)
      $('#start_date, #fake_start_date').datepicker('setDate', newStartDate)
}));


$("#start_date:not(:hidden)").datepicker('setDate', new Date());
$("#end_date:not(:hidden)").datepicker('setDate', 1);
