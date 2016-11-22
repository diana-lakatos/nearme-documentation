var el = $('#workflow_form');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/workflow_form_controller', function(require){
    var InstanceAdminWorkflowFormController = require('../../instance_admin/sections/workflow_form_controller');
    return new InstanceAdminWorkflowFormController(el);
  });
}
