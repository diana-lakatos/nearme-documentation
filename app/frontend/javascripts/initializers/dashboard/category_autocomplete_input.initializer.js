var els = $('[data-category-autocomplete]');
if (els.length > 0) {
  require.ensure('../../dashboard/modules/category_autocomplete_input', function(require) {
    var CategoryAutocompleteInput = require('../../dashboard/modules/category_autocomplete_input');
    els.each(function() {
      return new CategoryAutocompleteInput(this);
    });
  });
}
