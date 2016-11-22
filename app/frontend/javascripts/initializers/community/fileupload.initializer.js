var els = $('div[data-fileupload-wrapper]');
if (els.length > 0) {
  require.ensure('../../community/fileupload', function(require){
    var Fileupload = require('../../community/fileupload');
    els.each(function(){
      return new Fileupload(this);
    });
  });
}
