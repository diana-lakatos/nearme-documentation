var el = $('a[data-save-search]');
if (el.length > 0) {
  require.ensure('../../sections/search/save_search_controller', function(require){
    var SearchSaveSearchController = require('../../sections/search/save_search_controller');
    return new SearchSaveSearchController();
  });
}
