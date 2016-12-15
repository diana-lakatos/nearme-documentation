var els = $('.tutorial-a');
if (els.length > 0) {
  require.ensure('../tutorial', function(require){
    var Tutorial = require('../tutorial');
    els.each(function(){
      return new Tutorial(this);
    });
  });
}
