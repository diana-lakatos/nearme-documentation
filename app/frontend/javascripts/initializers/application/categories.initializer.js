var els = $('[data-categories-controller]');
if (els.length > 0) {
  require.ensure('../../sections/categories', function(require) {
    var CategoriesController = require('../../sections/categories');
    els.each(function() {
      var form = $(this).closest('form');
      return new CategoriesController(form);
    });
  });
}
