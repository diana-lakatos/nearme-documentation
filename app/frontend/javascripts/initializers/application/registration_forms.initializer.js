$(document).on('init:signinform.nearme', function(){
  require.ensure('../../sections/signin_form', function(require){
    var SigninForm = require('../../sections/signin_form');
    return new SigninForm($('#signup'));
  });
});

$(document).on('init:signupform.nearme', function(){
  require.ensure('../../sections/signup_form', function(require){
    var SignupForm = require('../../sections/signup_form');
    return new SignupForm($('#signup'));
  });
});
