var els = $('[data-popup]');
if (els.length > 0) {
  require.ensure('../../dashboard/modules/popup', function(require) {
    var Popup = require('../../dashboard/modules/popup');
    els.each(function() {
      return new Popup(this);
    });
  });
}
