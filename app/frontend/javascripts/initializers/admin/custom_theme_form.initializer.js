const form = document.getElementById('custom-theme-form');

if (form) {
  require.ensure('../../admin/sections/custom_theme_form', (require)=>{
    const CustomThemeForm = require('../../admin/sections/custom_theme_form');
    return new CustomThemeForm(form);
  });
}

