var els = $('.transactable-schedule-container');
if (els.length > 0) {
  require.ensure('../../dashboard/listings/schedule', function(require){
    var Schedule = require('../../dashboard/listings/schedule');
    els.each(function(){
      return new Schedule(this);
    });
  });
}
