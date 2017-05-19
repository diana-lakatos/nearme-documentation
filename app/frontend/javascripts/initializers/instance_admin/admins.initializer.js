var el = $('#instance_admins_form');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/admins/admins_controller', function(require) {
    var AdminsController = require('../../instance_admin/sections/admins/admins_controller');
    return new AdminsController(el);
  });
}
