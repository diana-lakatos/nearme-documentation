const form = document.getElementById('custom-theme-form');

if (form) {
  require.ensure('../sections/custom_theme_form', require => {
    const CustomThemeForm = require('../sections/custom_theme_form');
    return new CustomThemeForm(form);
  });
}
