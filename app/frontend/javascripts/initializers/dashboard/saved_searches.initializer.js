var els = $('table[data-saved-searches]');
if (els.length > 0) {
  require.ensure('../../dashboard/controllers/saved_searches_controller', function(require){
    var SavedSearchesController = require('../../dashboard/controllers/saved_searches_controller');
    els.each(function(){
      return new SavedSearchesController(this);
    });
  });
}
