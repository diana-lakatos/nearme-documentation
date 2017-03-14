'use strict';

if (!Modernizr.fetch) {
  require.ensure('whatwg-fetch', (require) => require('whatwg-fetch'));
}

import NM from 'nm';

NM.on('ready', () =>{
  require('admin/initializers/custom_theme_form.initializer');
  require('admin/initializers/dialog.initializer');
  require('admin/initializers/domain_record_form.initializer');
  require('admin/initializers/external_links.initializer');
  require('admin/initializers/general_modules.initializer');
  require('admin/initializers/navigation.initializer');
  require('admin/initializers/properties_form.initializer');
  require('admin/initializers/section_help.initializer');
  require('admin/initializers/versions_editor.initializer');
  require('admin/initializers/file_manager.initializer');
  require('admin/initializers/graphql_editor.initializer');

  require('admin/initializers/login_form.initializer');
});
