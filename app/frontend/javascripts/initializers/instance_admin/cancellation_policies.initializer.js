var el = document.querySelector('.new_transactable_type, .edit_transactable_type');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/cancellation_policies', function(require){
    var InstanceAdminCancellationPoliciesController = require('../../instance_admin/sections/cancellation_policies');
    return new InstanceAdminCancellationPoliciesController(el);
  });
}
