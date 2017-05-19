var el = $('#search-sortable');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/search', function(require) {
    var InstanceAdminSearchSettings = require('../../instance_admin/sections/search');
    return new InstanceAdminSearchSettings();
  });
}
