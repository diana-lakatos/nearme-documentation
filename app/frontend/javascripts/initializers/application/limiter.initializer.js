var els = $('[data-counter-limit]');
if (els.length > 0) {
  require.ensure('../../components/limiter', function(require){
    var Limiter = require('../../components/limiter');
    els.each(function(){
      return new Limiter(this);
    });
  });
}

