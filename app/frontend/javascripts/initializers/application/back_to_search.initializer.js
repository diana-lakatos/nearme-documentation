var el = $('[data-back-to-search-results-link]');
if (el.length > 0) {
  require.ensure('../../dashboard/modules/back_to_search', function(require){
    var BackToSearch = require('../../dashboard/modules/back_to_search');
    return new BackToSearch(el);
  });
}
