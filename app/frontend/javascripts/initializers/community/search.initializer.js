var els = $('#search_filter');
if (els.length > 0) {
  require.ensure('../../community/search/search', function(require){
    var Search = require('../../community/search/search');
    return new Search(els);
  });
}
