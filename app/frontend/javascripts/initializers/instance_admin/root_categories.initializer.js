var el = $('#root-category-tree');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/root_categories', function(require){
    var InstanceAdminRootCategoriesController = require('../../instance_admin/sections/root_categories');
    return new InstanceAdminRootCategoriesController(el);
  });
}

