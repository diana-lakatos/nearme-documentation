var els = $('[data-flash-message]');
if (els.length > 0) {
  require.ensure('../../community/flash_message', function(require){
    var FlashMessage = require('../../community/flash_message');
    els.each(function(){
      return new FlashMessage(this);
    });
  });
}

