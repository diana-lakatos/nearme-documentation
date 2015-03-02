#= require_self
#= require ./home/background_controller
#= require ./home/controller

@Home = {}

$('#start_date,#fake_start_date').datepicker({
  altFormat: 'yy-mm-dd',
  altField: '#availability_dates_start',
  dateFormat: 'mm/dd/yy',
  constrainInput: true,
  minDate: 0,
  showOtherMonths: true,
  selectOtherMonths: true,
  onClose: (selectedDate) ->
    $('#end_date, #fake_end_date').datepicker "option", "minDate", selectedDate
});

$('#end_date,#fake_end_date').datepicker({
  altFormat: 'yy-mm-dd',
  altField: '#availability_dates_end',
  dateFormat: 'mm/dd/yy',
  constrainInput: true,
  defaultDate: 7,
  minDate: 0,
  showOtherMonths: false
  selectOtherMonths: false,
  onClose: (selectedDate) ->
    $('#start_date, #fake_start_date').datepicker "option", "maxDate", selectedDate
});

$("#start_date").datepicker('setDate', new Date());
$("#end_date").datepicker('setDate', 7);
