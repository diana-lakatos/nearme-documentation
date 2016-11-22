var els = $('.multiselect');
if (els.length > 0) {
  require.ensure('../../components/multiselect', function(require){
    var Multiselect = require('../../components/multiselect');
    els.each(function(){
      return new Multiselect.initialize(this);
    });
  });
}

