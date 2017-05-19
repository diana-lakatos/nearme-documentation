var els = $('#reviews');
if (els.length > 0) {
  require.ensure('../../dashboard/reviews/reviews', function(require) {
    var Reviews = require('../../dashboard/reviews/reviews');
    els.each(function() {
      return new Reviews(this);
    });
  });
}
