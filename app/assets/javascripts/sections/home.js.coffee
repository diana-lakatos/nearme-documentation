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
  maxDate: 7,
  onClose: (selectedDate) ->
    $('#end_date, #fake_end_date').datepicker "option", "minDate", selectedDate
}));

$('#end_date, #fake_end_date').datepicker($.extend({}, common_options, {
  altField: '#availability_dates_end',
  defaultDate: 7,
  showOtherMonths: false
  selectOtherMonths: false,
  onClose: (selectedDate) ->
    $('#start_date, #fake_start_date').datepicker "option", "maxDate", selectedDate
}));


$("#start_date:not(:hidden)").datepicker('setDate', new Date());
$("#end_date:not(:hidden)").datepicker('setDate', 7);

$("#fake_start_date").datepicker 'option', 'maxDate', $('#fake_end_date').val()
$("#fake_end_date").datepicker 'option', 'minDate', $('#fake_start_date').val()
