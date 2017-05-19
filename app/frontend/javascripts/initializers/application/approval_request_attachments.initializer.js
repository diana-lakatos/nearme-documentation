$(document).on('init:approvalrequestattachmentscontroller.nearme', function(event, element) {
  require.ensure('../../sections/approval_request_attachments_controller', function(require) {
    var ApprovalRequestAttachmentsController = require(
      '../../sections/approval_request_attachments_controller'
    );
    return new ApprovalRequestAttachmentsController(element);
  });
});
