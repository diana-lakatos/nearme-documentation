var Flash;

Flash = function() {
  function Flash(scope) {
    if (scope == null) {
      scope = 'body';
    }
    this.scope = $(scope);
    this.bindEvents();
    this.initialize();
  }

  Flash.prototype.initialize = function() {
    return this.scope
      .find('div[data-flash-message]')
      .css({ 'display': 'none' })
      .delay(200)
      .css({ 'display': 'block' });
  };

  Flash.prototype.bindEvents = function(scope) {
    if (scope == null) {
      scope = $('body');
    }
    return this.scope.on('click', 'div[data-flash-message]', function(event) {
      if (!$(event.target).attr('href') || $(event.target).hasClass('close')) {
        $(event.target).closest('div[data-flash-message]').remove();
        return event.preventDefault();
      }
    });
  };

  return Flash;
}();

module.exports = Flash;
