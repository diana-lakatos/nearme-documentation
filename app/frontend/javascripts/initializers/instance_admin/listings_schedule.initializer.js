var el = $('.transactable-schedule-container');
if (el.length > 0) {
  require.ensure('../../dashboard/listings/schedule', function(require) {
    var ListingsSchedule = require('../../dashboard/listings/schedule');
    return new ListingsSchedule(el);
  });
}
