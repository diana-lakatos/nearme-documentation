var els = $('.selectize-tags');
if (els.length > 0) {
  require.ensure('../../dashboard/modules/tags', function(require){
    var Tags = require('../../dashboard/modules/tags');
    els.each(function(){
      return new Tags(this);
    });
  });
}
