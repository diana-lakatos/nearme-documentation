//Prefences Checkbox slide
var cancellationSettings = $('.cancellation-settings').hide();
var passwordSettings = $('.password-settings').hide();


$('#cancellation-check').on('change', function() {
  if($(this).is(':checked')) {
    return cancellationSettings.slideDown();
  }
  cancellationSettings.slideUp();
});

$('#password-check').on('change', function() {
  if($(this).is(':checked')) {
    return passwordSettings.slideDown();
  }
  passwordSettings.slideUp();
});
