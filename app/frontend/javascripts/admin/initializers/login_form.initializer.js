let form = document.querySelector('[data-login-form]');
if (form && form instanceof HTMLFormElement) {
  require.ensure('../sections/login/login_form', require => {
    let LoginForm = require('../sections/login/login_form');
    new LoginForm(form);
  });
}
