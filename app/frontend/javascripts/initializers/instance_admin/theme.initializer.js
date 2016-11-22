var el = $('#theme_form');
if (el.length === 0) {
  require.ensure('../../instance_admin/sections/theme', function(require){
    var ThemeController = require('../../instance_admin/sections/theme');
    return new ThemeController(el);
  });
}

