var el = $('ol.formComponentPanelList');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/form_components', function(require) {
    var FormComponents = require('../../instance_admin/sections/form_components');
    return new FormComponents(el);
  });
}

var manager = $('#form-components-manager');
if (manager.length > 0) {
  require.ensure('../../instance_admin/sections/form_components_manager', function(require) {
    var InstanceAdminFormComponentsManager = require(
      '../../instance_admin/sections/form_components_manager'
    );
    return new InstanceAdminFormComponentsManager(manager);
  });
}
