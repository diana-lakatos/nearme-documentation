var el = $('table#pages');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/pages', function(require){
    var PagesController = require('../../instance_admin/sections/pages');
    return new PagesController(el);
  });
}

