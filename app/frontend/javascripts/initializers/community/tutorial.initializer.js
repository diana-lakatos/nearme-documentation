var els = $('.tutorial-a');
if (els.length > 0) {
  require.ensure('../../community/tutorial', function(require){
    var Tutorial = require('../../community/tutorial');
    els.each(function(){
      return new Tutorial(this);
    });
  });
}
