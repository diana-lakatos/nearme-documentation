var el = $('table#faqs');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/support/faqs', function(require){
    var FaqsController = require('../../instance_admin/sections/support/faqs');
    return new FaqsController(el);
  });
}

