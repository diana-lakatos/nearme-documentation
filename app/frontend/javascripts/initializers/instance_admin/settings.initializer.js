var modal = $('.settings-controller-modal #instanceAdminModal');

if (modal.length > 0) {
  require.ensure('../../instance_admin/sections/settings', function(require) {
    var InstanceAdminSettingsController = require('../../instance_admin/sections/settings');
    return new InstanceAdminSettingsController(modal);
  });
}
