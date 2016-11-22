var el = $('article#space');
if (el.length > 0) {
  require.ensure('../../sections/space/controller', function(require){
    var SpaceController = require('../../sections/space/controller');
    return new SpaceController(el);
  });
}
