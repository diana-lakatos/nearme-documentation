var MessagesController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

MessagesController = function() {
  function MessagesController(container) {
    this.resetValidationUI = bind(this.resetValidationUI, this);
    this.validate = bind(this.validate, this);
    this.container = $(container);
    this.form = this.container.find('form');
    this.message_field = this.form.find('[data-message-body]');
    this.message_field_group = this.message_field.closest('.form-group');
    this.submit_button = this.form.find('[type=submit]');
    this.thread = $('.inbox-thread');
    this.errors = [];
    this.bindEvents();
  }

  MessagesController.prototype.validate = function() {
    var flag, message;
    flag = true;
    message = this.message_field.val();
    if ($.trim(message) === '') {
      flag = false;
      this.message_field_group.addClass('has-error');
      this.message_field_group.append('<span class="help-block">Message can’t be blank</span>');
    }
    return flag;
  };
  MessagesController.prototype.resetValidationUI = function() {
    this.form.find('span.help-block').remove();
    return this.form.find('.form-group.has-error').removeClass('has-error');
  };
  MessagesController.prototype.bindEvents = function() {
    this.form.on(
      'submit',
      function(_this) {
        return function() {
          var is_valid;
          _this.resetValidationUI();
          is_valid = _this.validate();
          return is_valid;
        };
      }(this)
    );
    this.form.on(
      'ajax:beforeSend',
      function(_this) {
        return function() {
          return _this.submit_button.attr('disabled', 'disabled').val('Sending...');
        };
      }(this)
    );
    this.form.on(
      'ajax:success',
      function(_this) {
        return function(e, data) {
          return _this.thread.append(data);
        };
      }(this)
    );
    return this.form.on(
      'ajax:complete',
      function(_this) {
        return function() {
          _this.submit_button.removeAttr('disabled').val('Send');
          return _this.message_field.val('');
        };
      }(this)
    );
  };
  return MessagesController;
}();
module.exports = MessagesController;
