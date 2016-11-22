var el = $('#category_form');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/categories', function(require){
    var InstanceAdminCategoriesController = require('../../instance_admin/sections/categories');
    return new InstanceAdminCategoriesController(el);
  });
}



