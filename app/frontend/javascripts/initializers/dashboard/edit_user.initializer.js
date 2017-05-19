var els = $('.services_list');
if (els.length > 0) {
  require.ensure('../../dashboard/controllers/edit_user_controller', function(require) {
    var EditUserController = require('../../dashboard/controllers/edit_user_controller');
    els.each(function() {
      return new EditUserController(this);
    });
  });
}
