'use strict';

if (!Modernizr.promises) {
  require.ensure('es6-promise', (require) => require('es6-promise').polyfill());
}

if (!Modernizr.fetch) {
  require.ensure('whatwg-fetch', (require) => require('whatwg-fetch'));
}

require('svgxuse');

/* Support for IE10 */
require('element-dataset');

import NM from 'nm';

NM.on('ready', ()=>{
  require('initializers/admin/custom_theme_form.initializer');
  require('initializers/admin/dialog.initializer');
  require('initializers/admin/domain_record_form.initializer');
  require('initializers/admin/external_links.initializer');
  require('initializers/admin/general_modules.initializer');
  require('initializers/admin/navigation.initializer');
  require('initializers/admin/properties_form.initializer');
  require('initializers/admin/section_help.initializer');
  require('initializers/admin/versions_editor.initializer');
  require('initializers/admin/file_manager.initializer');
  require('initializers/admin/graphql_editor.initializer');
});
