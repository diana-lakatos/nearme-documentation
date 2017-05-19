var FlashMessage;

FlashMessage = function() {
  function FlashMessage() {
    this.bindEvents();
  }

  FlashMessage.prototype.bindEvents = function() {
    return $('body').on('click', '[data-flash-message] [data-close]', function(e) {
      e.preventDefault();
      return $(e.target).closest('[data-flash-message]').remove();
    });
  };

  return FlashMessage;
}();

module.exports = FlashMessage;
