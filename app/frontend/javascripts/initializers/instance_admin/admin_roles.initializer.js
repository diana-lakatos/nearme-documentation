var el = $('#instance_admin_roles');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/admins/admin_roles_controller', function(require) {
    var AdminRolesController = require(
      '../../instance_admin/sections/admins/admin_roles_controller'
    );
    return new AdminRolesController(el);
  });
}
