var ChosenInitializer = require('../../instance_admin/forms/chosen');
function run() {
  new ChosenInitializer();
}
$(document).on('cocoon:after-insert', run);
run();
