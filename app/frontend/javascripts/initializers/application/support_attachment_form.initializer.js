$(document).on('init:supportattachmentform.nearme', function() {
  require.ensure('../../sections/support/attachment_form', function(require) {
    var SupportAttachmentForm = require('../../sections/support/attachment_form');
    return new SupportAttachmentForm($('#attachment_form'));
  });
});

var form = $('#attachment_form');
if (form.length > 0) {
  require.ensure('../../sections/support/attachment_form', function(require) {
    var SupportAttachmentForm = require('../../sections/support/attachment_form');
    return new SupportAttachmentForm(form);
  });
}
