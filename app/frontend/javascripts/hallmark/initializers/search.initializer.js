var els = $('#search_filter');
if (els.length > 0) {
  require.ensure('../search/search', function(require){
    var Search = require('../search/search');
    return new Search(els);
  });
}
