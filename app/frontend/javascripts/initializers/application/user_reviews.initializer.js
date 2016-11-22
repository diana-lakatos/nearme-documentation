var els = $('#reviews');
if (els.length > 0) {
  require.ensure('../../sections/registrations/user_reviews', function(require){
    var UserReviews = require('../../sections/registrations/user_reviews');
    return new UserReviews(els);
  });
}
