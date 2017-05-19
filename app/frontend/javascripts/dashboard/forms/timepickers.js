var timepickers;

require('timepicker/jquery.timepicker');

timepickers = function(context) {
  if (context == null) {
    context = 'body';
  }
  return $(context).find('input.time_picker').each(function() {
    var input;
    input = $(this);
    input.timepicker({ timeFormat: input.data('jsformat') });
    return input.next('.input-group-addon').on('click', function() {
      return input.timepicker('show');
    });
  });
};

module.exports = timepickers;
