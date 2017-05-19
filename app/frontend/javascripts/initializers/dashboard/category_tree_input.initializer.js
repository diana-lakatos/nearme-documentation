var els = $('[data-category-tree-input]');
if (els.length > 0) {
  require.ensure('../../dashboard/modules/category_tree_input', function(require) {
    var CategoryTreeInput = require('../../dashboard/modules/category_tree_input');
    els.each(function() {
      return new CategoryTreeInput(this);
    });
  });
}
