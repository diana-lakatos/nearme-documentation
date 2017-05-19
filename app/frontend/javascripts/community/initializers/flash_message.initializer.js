var els = $('[data-flash-message]');
if (els.length > 0) {
  require.ensure('../flash_message', function(require) {
    var FlashMessage = require('../flash_message');
    els.each(function() {
      return new FlashMessage(this);
    });
  });
}
