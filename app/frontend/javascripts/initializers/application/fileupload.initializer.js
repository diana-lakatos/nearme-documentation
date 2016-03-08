var els = $('div[data-fileupload-wrapper]');
if (els.length > 0) {
  require.ensure('../../components/fileupload', function(require){
    var Fileupload = require('../../components/fileupload');
    els.each(function(){
      return new Fileupload(this);
    });
  });
}

