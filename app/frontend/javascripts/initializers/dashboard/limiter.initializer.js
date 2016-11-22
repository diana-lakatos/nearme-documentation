$(document).on('init:limiter.nearme', function(event, elements){
  require.ensure('../../dashboard/modules/limited_input', function(require){
    var Limiter = require('../../dashboard/modules/limited_input');
    $(elements).each(function(){
      return new Limiter(this);
    });
  });
});

var els = $('[data-counter-limit]');
if (els.length > 0) {
  require.ensure('../../dashboard/modules/limited_input', function(require){
    var Limiter = require('../../dashboard/modules/limited_input');
    els.each(function(){
      return new Limiter(this);
    });
  });
}
