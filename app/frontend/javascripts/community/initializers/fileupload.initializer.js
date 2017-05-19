var els = $('div[data-fileupload-wrapper]');
if (els.length > 0) {
  require.ensure('../fileupload', function(require) {
    var Fileupload = require('../fileupload');
    els.each(function() {
      return new Fileupload(this);
    });
  });
}
