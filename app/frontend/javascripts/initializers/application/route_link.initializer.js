var els = $('[data-routelink]');
if (els.length > 0) {
  require.ensure('../../components/route_link', function(require){
    var RouteLink = require('../../components/route_link');
    els.each(function(){
      return new RouteLink($(this));
    });
  });
}
