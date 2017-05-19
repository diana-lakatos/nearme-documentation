var wrapper = document.querySelector('.social-buttons-wrapper');

if (wrapper) {
  require.ensure([ '../../vendor/socialite', '../../dashboard/modules/social_buttons' ], function(
    require
  ) {
    var SocialButtons = require('../../dashboard/modules/social_buttons');
    require('../../vendor/socialite');

    return new SocialButtons(wrapper, window.Socialite);
  });
}
