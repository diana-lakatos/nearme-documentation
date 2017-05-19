var Modal, SupportTicketMessageController;

Modal = require('../../components/modal');

SupportTicketMessageController = function() {
  function SupportTicketMessageController(container) {
    this.container = container;
    this.form = this.container.find('form[data-attachment-form]');
    this.uploadAttachment = this.container.find('a[data-upload]');
    this.fileUpload = this.form.find('input[data-file]');
    this.attachmentList = this.container.find('[data-attachment-list]');
    this.template = this.attachmentList.find('[data-template]');
    this.modal = $('#bootstrap-modal');
    this.bindEvents();
  }

  SupportTicketMessageController.prototype.bindEvents = function() {
    this.attachmentList.on(
      'click',
      function(_this) {
        return function(e) {
          var a;
          e.preventDefault();
          a = $(e.target).closest('a');
          if (a.data('delete') && confirm(a.data('delete'))) {
            return $.ajax({
              type: 'POST',
              url: a.attr('href'),
              data: { '_method': 'delete' },
              success: function() {
                return a.closest('.attachment').fadeOut('slow', function() {
                  return $(this).remove();
                });
              },
              error: function() {
                return Modal.showContent(_this.uploadAttachment.data('destroy-error'));
              }
            });
          }
        };
      }(this)
    );
    this.uploadAttachment.on(
      'click',
      function(_this) {
        return function(e) {
          e.preventDefault();
          return _this.fileUpload.click();
        };
      }(this)
    );
    return this.form.find('input:file').on(
      'change',
      function(_this) {
        return function(event) {
          return $.each($(event.target)[0].files, function(key, file) {
            if (_this.modal.length > 0) {
              _this.modal.modal('show');
            } else {
              Modal.showContent(_this.uploadAttachment.data('uploading'));
            }
            _this.data = new FormData();
            _this.data.append('support_ticket_message_attachment[file]', file);
            _this.data.append('form_name', _this.uploadAttachment.data('form-name'));
            return $.ajax({
              type: 'POST',
              url: _this.form.attr('action'),
              data: _this.data,
              dataType: 'JSON',
              cache: false,
              processData: false,
              contentType: false,
              success: function(data) {
                _this.attachmentList.append(data.attachment_content);
                if (_this.modal.length > 0) {
                  return _this.modal.find('.modal-body').html(data.modal_content);
                } else {
                  return Modal.showContent(data.modal_content);
                }
              },
              error: function(xhr) {
                var error_message, validJson;
                try {
                  validJson = JSON.parse(xhr.responseText);
                } catch (error) {
                  validJson = false;
                }
                if (validJson && validJson.error_message) {
                  error_message = validJson.error_message;
                } else {
                  error_message = _this.uploadAttachment.data('error');
                }
                if (_this.modal.length > 0) {
                  return _this.modal.find('.modal-body').html(error_message);
                } else {
                  return Modal.showContent(error_message);
                }
              }
            });
          });
        };
      }(this)
    );
  };

  return SupportTicketMessageController;
}();

module.exports = SupportTicketMessageController;
