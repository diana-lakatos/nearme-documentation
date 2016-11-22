var el = $('.approval_requests');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/approval_requests', function(require){
    var InstanceAdminApprovalRequestsController = require('../../instance_admin/sections/approval_requests');
    return new InstanceAdminApprovalRequestsController(el);
  });
}
