var dateInput = $('[data-jquery-datepicker]');
if (dateInput.length > 0) {
  require.ensure(
    [ '../../sections/search/time_and_datepickers', '../../dashboard/forms/timepickers' ],
    function(require) {
      var SearchTimeAndDatepickers = require('../../sections/search/time_and_datepickers');
      return new SearchTimeAndDatepickers(dateInput);
    }
  );
}
