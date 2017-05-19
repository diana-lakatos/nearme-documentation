var el = $('form[data-partner-form]');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/partners', function(require) {
    var PartnersController = require('../../instance_admin/sections/partners');
    return new PartnersController(el);
  });
}
