var els = $('[data-reviews-controller]');
if (els.length > 0) {
  require.ensure('../../sections/reviews/controller', function(require){
    var ReviewsController = require('../../sections/reviews/controller');
    els.each(function(){
      return new ReviewsController($(this), { path: $(this).data('path'), reviewables: $(this).data('reviewables') });
    });
  });
}
