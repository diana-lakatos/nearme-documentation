var TicketMessageController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

TicketMessageController = function() {
  function TicketMessageController(el) {
    this.submitForm = bind(this.submitForm, this);
    this.deleteAttachment = bind(this.deleteAttachment, this);
    this.container = $(el);
    this.form = this.container.find('[data-rfq-attachment-form]');
    this.input = this.form.find('input[data-file]');
    this.attachmentList = this.container.find('[data-attachment-list]');
    this.label = this.container.find('[data-attachment-label]');
    this.labelTextHolder = this.label.find('span');
    this.labelText = {
      'default': this.labelTextHolder.text(),
      uploading: this.label.data('attachment-label')
    };
    this.bindEvents();
  }

  TicketMessageController.prototype.initializeLabel = function() {};

  TicketMessageController.prototype.bindEvents = function() {
    this.attachmentList.on('click', 'a[data-delete]', this.deleteAttachment);
    this.input.on('change', this.submitForm);
    return this.attachmentList.on('change', 'select', this.updateTag);
  };

  TicketMessageController.prototype.deleteAttachment = function(e) {
    var a;
    e.preventDefault();
    a = $(e.target).closest('a');
    if (!confirm(a.data('delete'))) {
      return;
    }
    return $.ajax({
      type: 'POST',
      url: a.attr('href'),
      data: { '_method': 'delete' },
      success: function() {
        return a.closest('.attachment').remove();
      },
      error: function(_this) {
        return function() {
          return alert(_this.input.data('destroy-error'));
        };
      }(this)
    });
  };

  TicketMessageController.prototype.updateTag = function(e) {
    var data;
    data = { '_method': 'put', 'support_ticket_message_attachment[tag]': $(e.target).val() };
    return $.ajax({
      type: 'POST',
      url: $(e.target).closest('[data-update-url]').data('update-url'),
      data: data,
      error: function() {
        return alert('Unable to change attachment tag');
      }
    });
  };

  TicketMessageController.prototype.submitForm = function() {
    return $.each(
      this.input.get(0).files,
      function(_this) {
        return function(key, file) {
          var data;
          data = new FormData();
          data.append('support_ticket_message_attachment[file]', file);
          data.append('form_name', _this.input.data('form-name'));
          _this.label.addClass('uploading');
          _this.labelTextHolder.text(_this.labelText.uploading);
          return $.ajax({
            type: 'POST',
            url: _this.form.attr('action'),
            data: data,
            dataType: 'JSON',
            cache: false,
            processData: false,
            contentType: false,
            success: function(data) {
              var new_item;
              _this.label.removeClass('uploading');
              _this.labelTextHolder.text(_this.labelText['default']);
              new_item = $(data.attachment_content);
              _this.attachmentList.append(data.attachment_content);
              return $('html').trigger('selects.init.forms', [ new_item ]);
            },
            error: function() {
              return alert(_this.input.data('error'));
            }
          });
        };
      }(this)
    );
  };

  return TicketMessageController;
}();

module.exports = TicketMessageController;
