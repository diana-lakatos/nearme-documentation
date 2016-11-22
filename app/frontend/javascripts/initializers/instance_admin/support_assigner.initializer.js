var el = $('#user_assigned_to_id');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/support_assigner', function(require){
    var SupportAssigner = require('../../instance_admin/sections/support_assigner');
    return new SupportAssigner(el);
  });
}

