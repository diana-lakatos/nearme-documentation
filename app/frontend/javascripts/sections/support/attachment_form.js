var Modal, SupportAttachmentForm;

Modal = require('../../components/modal');

SupportAttachmentForm = function() {
  function SupportAttachmentForm(form) {
    this.form = form;
    this.bindEvents();
    this.attachmentList = $('[data-attachment-list]');
  }

  SupportAttachmentForm.prototype.bindEvents = function() {
    return this.form.submit(
      function(_this) {
        return function() {
          $.ajax({
            type: 'POST',
            url: _this.form.attr('action'),
            data: _this.form.serialize(),
            success: function(data) {
              $(
                '#support_ticket_message_attachment_' + data.attachment_id
              ).replaceWith(data.attachment_content);
              return Modal.close();
            },
            error: function(xhr) {
              return Modal.showContent(xhr.responseText);
            }
          });
          return false;
        };
      }(this)
    );
  };

  return SupportAttachmentForm;
}();

module.exports = SupportAttachmentForm;
