var datepickers = require('../../dashboard/forms/datepickers');
function run(){
  $('.unavailability').on('cocoon:after-insert', function(e, insertedItem) {
    datepickers(insertedItem);
  });
}
$(document).on('init:unavailability.nearme', run);
run();
