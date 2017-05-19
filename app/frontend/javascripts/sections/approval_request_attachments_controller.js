var ApprovalRequestAttachmentsController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

ApprovalRequestAttachmentsController = function() {
  function ApprovalRequestAttachmentsController(container) {
    this.bindEvents = bind(this.bindEvents, this);
    this.container = $(container);
    this.bindEvents();
  }

  ApprovalRequestAttachmentsController.prototype.bindEvents = function() {
    return this.container.on('ajax:success', 'a[data-delete-attachment]', function(event) {
      return $(event.target).parent().html('');
    });
  };

  return ApprovalRequestAttachmentsController;
}();

module.exports = ApprovalRequestAttachmentsController;
